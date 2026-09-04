import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";

export async function createFichier(filename: string, mimeType: string, data: Buffer) {
  const fichier = await prisma.fichier.create({ data: { filename, mimeType, data } });
  return fichier.id;
}

export async function getFichier(id: string) {
  const fichier = await prisma.fichier.findUnique({ where: { id } });
  if (!fichier) {
    throw ApiError.notFound("Fichier introuvable");
  }
  return fichier;
}
