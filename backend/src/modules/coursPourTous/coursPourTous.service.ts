import { User } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toCoursResponse } from "../../utils/mappers";
import { z } from "zod";
import { createCoursSchema, updateCoursSchema } from "./coursPourTous.schemas";

async function withPlacesRestantes(coursId: string, placesDisponibles: number) {
  const count = await prisma.inscriptionCoursPourTous.count({ where: { coursId } });
  return Math.max(placesDisponibles - count, 0);
}

export async function listCours() {
  // "Campagnes a venir" : on n'affiche que celles dont la date de fin n'est pas encore passee.
  const coursList = await prisma.coursPourTous.findMany({
    where: { dateFin: { gte: new Date() } },
    orderBy: { dateDebut: "asc" },
  });

  return Promise.all(
    coursList.map(async (cours) =>
      toCoursResponse(cours, await withPlacesRestantes(cours.id, cours.placesDisponibles))
    )
  );
}

async function getCoursOrThrow(id: string) {
  const cours = await prisma.coursPourTous.findUnique({ where: { id } });
  if (!cours) {
    throw ApiError.notFound("Cours pour tous introuvable");
  }
  return cours;
}

export async function createCours(body: z.infer<typeof createCoursSchema>) {
  const cours = await prisma.coursPourTous.create({ data: body });
  return toCoursResponse(cours, cours.placesDisponibles);
}

export async function updateCours(id: string, body: z.infer<typeof updateCoursSchema>) {
  await getCoursOrThrow(id);
  const updated = await prisma.coursPourTous.update({ where: { id }, data: body });
  return toCoursResponse(updated, await withPlacesRestantes(id, updated.placesDisponibles));
}

export async function deleteCours(id: string) {
  await getCoursOrThrow(id);
  await prisma.coursPourTous.delete({ where: { id } });
}

export async function inscrire(user: User, coursId: string, studentId: string) {
  const cours = await getCoursOrThrow(coursId);

  const student = await prisma.student.findUnique({ where: { id: studentId } });
  if (!student) {
    throw ApiError.notFound("Eleve introuvable");
  }
  const isOwner = student.parentId === user.id || student.userId === user.id;
  if (!isOwner && user.role !== "ADMIN") {
    throw ApiError.forbidden("Cet eleve ne vous appartient pas");
  }

  const existing = await prisma.inscriptionCoursPourTous.findUnique({
    where: { coursId_studentId: { coursId, studentId } },
  });
  if (existing) {
    throw ApiError.conflict("Cet eleve est deja inscrit a ce cours", "ALREADY_REGISTERED");
  }

  const placesRestantes = await withPlacesRestantes(coursId, cours.placesDisponibles);
  if (placesRestantes <= 0) {
    throw ApiError.conflict("Plus de places disponibles pour ce cours", "NO_PLACES_LEFT");
  }

  await prisma.inscriptionCoursPourTous.create({ data: { coursId, studentId } });

  const updatedPlacesRestantes = await withPlacesRestantes(coursId, cours.placesDisponibles);
  return toCoursResponse(cours, updatedPlacesRestantes);
}
