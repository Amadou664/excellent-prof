import { z } from "zod";
import { AnnonceType, Visibilite } from "@prisma/client";

export const createAnnonceSchema = z.object({
  titre: z.string().min(1),
  contenu: z.string().min(1),
  type: z.nativeEnum(AnnonceType),
  visibilite: z.nativeEnum(Visibilite).default("PUBLIC"),
  imageUrl: z.string().url().optional(),
});

export const updateAnnonceSchema = z.object({
  titre: z.string().min(1).optional(),
  contenu: z.string().min(1).optional(),
  type: z.nativeEnum(AnnonceType).optional(),
  visibilite: z.nativeEnum(Visibilite).optional(),
  imageUrl: z.string().url().nullable().optional(),
});
