import { User } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toCahierResponse, toSeanceResponse } from "../../utils/mappers";
import { z } from "zod";
import { cahierTexteSchema, createSeanceSchema } from "./seances.schemas";

export async function getMine(user: User) {
  const where =
    user.role === "PROFESSEUR"
      ? { professeurId: user.id }
      : { demande: { student: { OR: [{ parentId: user.id }, { userId: user.id }] } } };

  const seances = await prisma.seance.findMany({
    where,
    orderBy: { dateSeance: "desc" },
  });
  return seances.map(toSeanceResponse);
}

export async function createSeance(user: User, body: z.infer<typeof createSeanceSchema>) {
  const demande = await prisma.demande.findUnique({ where: { id: body.demandeId } });
  if (!demande) {
    throw ApiError.notFound("Demande introuvable");
  }
  if (!demande.professeurId) {
    throw ApiError.conflict("Cette demande n'a pas encore de professeur assigne");
  }
  if (user.role === "PROFESSEUR" && demande.professeurId !== user.id) {
    throw ApiError.forbidden("Vous n'etes pas le professeur assigne a cette demande");
  }

  const seance = await prisma.seance.create({
    data: {
      demandeId: demande.id,
      professeurId: demande.professeurId,
      dateSeance: body.dateSeance,
      statut: "PLANIFIEE",
    },
  });
  return toSeanceResponse(seance);
}

async function getSeanceOrThrow(id: string) {
  const seance = await prisma.seance.findUnique({
    where: { id },
    include: { demande: { include: { student: true } } },
  });
  if (!seance) {
    throw ApiError.notFound("Seance introuvable");
  }
  return seance;
}

export async function updateStatut(user: User, id: string, statut: "EFFECTUEE" | "ANNULEE") {
  const seance = await getSeanceOrThrow(id);
  // requireRole ne verifie que le type de role, pas la propriete de la seance : sans ce
  // controle, n'importe quel PROFESSEUR pourrait modifier le statut de la seance d'un autre
  // professeur.
  if (user.role === "PROFESSEUR" && seance.professeurId !== user.id) {
    throw ApiError.forbidden("Vous n'etes pas le professeur assigne a cette seance");
  }
  const updated = await prisma.seance.update({ where: { id }, data: { statut } });
  return toSeanceResponse(updated);
}

function assertCanAccessSeance(
  user: User,
  seance: Awaited<ReturnType<typeof getSeanceOrThrow>>
) {
  if (user.role === "ADMIN") return;
  if (user.role === "PROFESSEUR" && seance.professeurId === user.id) return;
  const student = seance.demande.student;
  if (student.parentId === user.id || student.userId === user.id) return;
  throw ApiError.forbidden("Acces refuse a cette seance");
}

export async function upsertCahierTexte(
  user: User,
  seanceId: string,
  body: z.infer<typeof cahierTexteSchema>
) {
  const seance = await getSeanceOrThrow(seanceId);
  if (seance.professeurId !== user.id) {
    throw ApiError.forbidden("Vous n'etes pas le professeur assigne a cette seance");
  }

  const cahier = await prisma.cahierDeTexte.upsert({
    where: { seanceId },
    create: { seanceId, ...body },
    update: { ...body },
  });
  return toCahierResponse(cahier);
}

export async function getCahierTexte(user: User, seanceId: string) {
  const seance = await getSeanceOrThrow(seanceId);
  assertCanAccessSeance(user, seance);

  const cahier = await prisma.cahierDeTexte.findUnique({ where: { seanceId } });
  if (!cahier) {
    throw ApiError.notFound("Aucun cahier de texte pour cette seance");
  }
  return toCahierResponse(cahier);
}
