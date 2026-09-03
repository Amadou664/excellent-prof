import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toAnnonceResponse } from "../../utils/mappers";
import { z } from "zod";
import { createAnnonceSchema, updateAnnonceSchema } from "./annonces.schemas";

export async function listAnnonces(isAuthenticated: boolean) {
  const annonces = await prisma.annonce.findMany({
    where: isAuthenticated ? {} : { visibilite: "PUBLIC" },
    orderBy: { datePublication: "desc" },
  });
  return annonces.map(toAnnonceResponse);
}

export async function createAnnonce(body: z.infer<typeof createAnnonceSchema>) {
  const annonce = await prisma.annonce.create({
    data: {
      titre: body.titre,
      contenu: body.contenu,
      type: body.type,
      visibilite: body.visibilite,
      imageUrl: body.imageUrl,
    },
  });
  return toAnnonceResponse(annonce);
}

export async function updateAnnonce(id: string, body: z.infer<typeof updateAnnonceSchema>) {
  const existing = await prisma.annonce.findUnique({ where: { id } });
  if (!existing) {
    throw ApiError.notFound("Annonce introuvable");
  }
  const updated = await prisma.annonce.update({
    where: { id },
    data: {
      ...(body.titre !== undefined ? { titre: body.titre } : {}),
      ...(body.contenu !== undefined ? { contenu: body.contenu } : {}),
      ...(body.type !== undefined ? { type: body.type } : {}),
      ...(body.visibilite !== undefined ? { visibilite: body.visibilite } : {}),
      ...(body.imageUrl !== undefined ? { imageUrl: body.imageUrl } : {}),
    },
  });
  return toAnnonceResponse(updated);
}

export async function deleteAnnonce(id: string) {
  const existing = await prisma.annonce.findUnique({ where: { id } });
  if (!existing) {
    throw ApiError.notFound("Annonce introuvable");
  }
  await prisma.annonce.delete({ where: { id } });
}
