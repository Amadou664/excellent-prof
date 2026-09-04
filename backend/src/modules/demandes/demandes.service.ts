import { Prisma, User } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toDemandeResponse } from "../../utils/mappers";
import { sendPushToUser } from "../../utils/push";
import { z } from "zod";
import {
  createDemandeSchema,
  listDemandesQuerySchema,
  updatePaiementSchema,
} from "./demandes.schemas";

async function assertStudentOwnedByUser(studentId: string, user: User) {
  const student = await prisma.student.findUnique({ where: { id: studentId } });
  if (!student) {
    throw ApiError.notFound("Eleve introuvable");
  }
  const isOwner = student.parentId === user.id || student.userId === user.id;
  if (!isOwner && user.role !== "ADMIN") {
    throw ApiError.forbidden("Cet eleve ne vous appartient pas");
  }
  return student;
}

export async function createDemande(user: User, body: z.infer<typeof createDemandeSchema>) {
  await assertStudentOwnedByUser(body.studentId, user);

  const demande = await prisma.demande.create({
    data: {
      studentId: body.studentId,
      matiere: body.matiere,
      modePref: body.modePref,
      notes: body.notes,
      status: "NOUVELLE",
    },
  });
  return toDemandeResponse(demande);
}

export async function getMine(user: User) {
  // "Mes demandes" depend du role : un PARENT/ETUDIANT/PARTICULIER voit les demandes de ses
  // students, tandis qu'un PROFESSEUR n'a aucun Student a lui — pour lui, "mine" designe les
  // demandes qui lui ont ete proposees/confirmees (via Demande.professeurId). Sans ce cas, un
  // professeur n'aurait aucun moyen de decouvrir les demandes en attente de sa confirmation.
  const where: Prisma.DemandeWhereInput =
    user.role === "PROFESSEUR"
      ? { professeurId: user.id }
      : { student: { OR: [{ parentId: user.id }, { userId: user.id }] } };

  const demandes = await prisma.demande.findMany({
    where,
    orderBy: { createdAt: "desc" },
  });
  return demandes.map(toDemandeResponse);
}

export async function listDemandes(query: z.infer<typeof listDemandesQuerySchema>) {
  const where: Prisma.DemandeWhereInput = {};
  if (query.status) where.status = query.status;
  const demandes = await prisma.demande.findMany({
    where,
    orderBy: { createdAt: "asc" },
  });
  return demandes.map(toDemandeResponse);
}

async function getDemandeOrThrow(id: string) {
  const demande = await prisma.demande.findUnique({ where: { id } });
  if (!demande) {
    throw ApiError.notFound("Demande introuvable");
  }
  return demande;
}

const TERMINAL_STATUSES = ["TERMINEE", "ANNULEE"] as const;

export async function assigner(demandeId: string, professeurId: string) {
  const demande = await getDemandeOrThrow(demandeId);
  if (TERMINAL_STATUSES.includes(demande.status as (typeof TERMINAL_STATUSES)[number])) {
    throw ApiError.conflict(`Impossible d'assigner une demande au statut ${demande.status}`);
  }

  const professeur = await prisma.user.findUnique({ where: { id: professeurId } });
  if (!professeur || professeur.role !== "PROFESSEUR") {
    throw ApiError.badRequest("professeurId ne correspond a aucun professeur", "INVALID_PROFESSEUR");
  }

  const updated = await prisma.demande.update({
    where: { id: demandeId },
    data: { professeurId, status: "PROF_PROPOSE" },
  });

  await sendPushToUser(
    professeurId,
    "Nouvelle demande",
    `Une demande de cours en ${updated.matiere} vous a ete proposee.`
  );

  return toDemandeResponse(updated);
}

export async function confirmer(demandeId: string, professeur: User, dateSeance?: Date) {
  const demande = await getDemandeOrThrow(demandeId);
  if (demande.professeurId !== professeur.id) {
    throw ApiError.forbidden("Vous n'etes pas le professeur assigne a cette demande");
  }
  if (demande.status !== "PROF_PROPOSE") {
    throw ApiError.conflict(
      `Impossible de confirmer une demande au statut ${demande.status} (attendu: PROF_PROPOSE)`
    );
  }

  const [updatedDemande] = await prisma.$transaction([
    prisma.demande.update({ where: { id: demandeId }, data: { status: "CONFIRMEE" } }),
    prisma.seance.create({
      data: {
        demandeId,
        professeurId: professeur.id,
        dateSeance: dateSeance ?? new Date(),
        statut: "PLANIFIEE",
      },
    }),
  ]);

  const student = await prisma.student.findUnique({ where: { id: updatedDemande.studentId } });
  const familyOwnerId = student?.parentId ?? student?.userId;
  if (familyOwnerId) {
    await sendPushToUser(
      familyOwnerId,
      "Cours confirme",
      `Le professeur a confirme votre demande en ${updatedDemande.matiere}.`
    );
  }

  return toDemandeResponse(updatedDemande);
}

export async function updatePaiement(
  demandeId: string,
  body: z.infer<typeof updatePaiementSchema>
) {
  await getDemandeOrThrow(demandeId);
  const updated = await prisma.demande.update({
    where: { id: demandeId },
    data: {
      paye: body.paye,
      ...(body.montant !== undefined ? { montant: body.montant } : {}),
    },
  });
  return toDemandeResponse(updated);
}

export async function annuler(demandeId: string, user: User) {
  const demande = await getDemandeOrThrow(demandeId);

  if (user.role !== "ADMIN") {
    await assertStudentOwnedByUser(demande.studentId, user);
  }

  if (TERMINAL_STATUSES.includes(demande.status as (typeof TERMINAL_STATUSES)[number])) {
    throw ApiError.conflict(`Demande deja au statut terminal ${demande.status}`);
  }

  const updated = await prisma.demande.update({
    where: { id: demandeId },
    data: { status: "ANNULEE" },
  });
  return toDemandeResponse(updated);
}
