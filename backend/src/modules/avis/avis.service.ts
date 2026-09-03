import { User } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toAvisResponse } from "../../utils/mappers";
import { z } from "zod";
import { createAvisSchema } from "./avis.schemas";

/**
 * Recalcule TeacherProfile.noteMoyenne / nombreAvis a partir des Avis VISIBLE pour ce
 * professeur (API_CONTRACT.md: "recalcule noteMoyenne/nombreAvis").
 */
async function recalculateTeacherRating(professeurId: string) {
  const aggregate = await prisma.avis.aggregate({
    where: { professeurId, statut: "VISIBLE" },
    _avg: { note: true },
    _count: { _all: true },
  });

  const teacherProfile = await prisma.teacherProfile.findUnique({ where: { userId: professeurId } });
  if (!teacherProfile) return;

  await prisma.teacherProfile.update({
    where: { userId: professeurId },
    data: {
      noteMoyenne: aggregate._avg.note ?? 0,
      nombreAvis: aggregate._count._all,
    },
  });
}

export async function createAvis(auteur: User, body: z.infer<typeof createAvisSchema>) {
  const professeur = await prisma.user.findUnique({ where: { id: body.professeurId } });
  if (!professeur || professeur.role !== "PROFESSEUR") {
    throw ApiError.badRequest("professeurId ne correspond a aucun professeur", "INVALID_PROFESSEUR");
  }

  // Cree en MASQUE (file d'attente de moderation) — voir commentaire sur le modele Avis dans
  // prisma/schema.prisma. Un ADMIN le publie ensuite via PATCH /avis/:id/statut.
  const avis = await prisma.avis.create({
    data: {
      professeurId: body.professeurId,
      auteurId: auteur.id,
      note: body.note,
      commentaire: body.commentaire,
      statut: "MASQUE",
    },
  });

  await recalculateTeacherRating(body.professeurId);

  return toAvisResponse(avis);
}

export async function listAvisForProfesseur(professeurId: string) {
  await recalculateTeacherRating(professeurId);

  const avis = await prisma.avis.findMany({
    where: { professeurId, statut: "VISIBLE" },
    orderBy: { createdAt: "desc" },
  });
  return avis.map(toAvisResponse);
}

/**
 * File de moderation ADMIN : sans professeurId, tous les avis (VISIBLE + MASQUE) sont
 * retournes, MASQUE (en attente) en premier, pour que l'ecran de moderation puisse les traiter.
 */
export async function listAvisForModeration() {
  // Enum declare comme VISIBLE puis MASQUE -> orderBy desc place MASQUE (en attente) en tete.
  const avis = await prisma.avis.findMany({
    orderBy: [{ statut: "desc" }, { createdAt: "desc" }],
  });
  return avis.map(toAvisResponse);
}

export async function updateStatut(id: string, statut: "VISIBLE" | "MASQUE") {
  const avis = await prisma.avis.findUnique({ where: { id } });
  if (!avis) {
    throw ApiError.notFound("Avis introuvable");
  }
  const updated = await prisma.avis.update({ where: { id }, data: { statut } });
  await recalculateTeacherRating(avis.professeurId);
  return toAvisResponse(updated);
}

export async function deleteAvis(id: string) {
  const avis = await prisma.avis.findUnique({ where: { id } });
  if (!avis) {
    throw ApiError.notFound("Avis introuvable");
  }
  await prisma.avis.delete({ where: { id } });
  await recalculateTeacherRating(avis.professeurId);
}
