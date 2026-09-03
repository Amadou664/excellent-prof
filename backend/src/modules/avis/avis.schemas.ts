import { z } from "zod";
import { AvisStatut } from "@prisma/client";

export const createAvisSchema = z.object({
  professeurId: z.string().uuid(),
  note: z.number().int().min(1).max(5),
  commentaire: z.string().min(1),
});

// professeurId optionnel : fourni -> avis VISIBLE d'un prof (affichage public sur son profil) ;
// omis -> reserve a l'ADMIN, liste tous les avis (VISIBLE + MASQUE) pour la moderation.
export const listAvisQuerySchema = z.object({
  professeurId: z.string().uuid().optional(),
});

export const updateAvisStatutSchema = z.object({
  statut: z.nativeEnum(AvisStatut),
});
