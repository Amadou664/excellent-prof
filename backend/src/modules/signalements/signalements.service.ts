import { User } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toSignalementResponse } from "../../utils/mappers";
import { z } from "zod";
import { createSignalementSchema } from "./signalements.schemas";

export async function createSignalement(
  auteur: User,
  body: z.infer<typeof createSignalementSchema>
) {
  const demande = await prisma.demande.findUnique({
    where: { id: body.demandeId },
    include: { student: true },
  });
  if (!demande) {
    throw ApiError.notFound("Demande introuvable");
  }

  const familyOwnerId = demande.student.parentId ?? demande.student.userId;
  const isFamille = familyOwnerId === auteur.id;
  const isProfesseur = demande.professeurId === auteur.id;
  if (!isFamille && !isProfesseur) {
    throw ApiError.forbidden("Vous n'etes pas participant a cette demande");
  }

  const cibleId = isFamille ? demande.professeurId : familyOwnerId;
  if (!cibleId) {
    throw ApiError.conflict(
      "Aucun autre participant a signaler sur cette demande pour le moment",
      "NO_CIBLE"
    );
  }

  const signalement = await prisma.signalement.create({
    data: {
      auteurId: auteur.id,
      cibleId,
      demandeId: body.demandeId,
      motif: body.motif,
    },
  });
  return toSignalementResponse(signalement);
}

export async function listSignalements() {
  const signalements = await prisma.signalement.findMany({
    orderBy: [{ statut: "asc" }, { createdAt: "desc" }],
    include: {
      auteur: { select: { nom: true, prenom: true, email: true } },
      cible: { select: { nom: true, prenom: true, email: true, role: true } },
    },
  });
  return signalements.map((s) => ({
    ...toSignalementResponse(s),
    auteur: s.auteur,
    cible: s.cible,
  }));
}

export async function markTraite(id: string) {
  const signalement = await prisma.signalement.findUnique({ where: { id } });
  if (!signalement) {
    throw ApiError.notFound("Signalement introuvable");
  }
  const updated = await prisma.signalement.update({
    where: { id },
    data: { statut: "TRAITE" },
  });
  return toSignalementResponse(updated);
}
