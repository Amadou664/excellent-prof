import { z } from "zod";
import { DemandeStatus, ModePref } from "@prisma/client";

export const createDemandeSchema = z.object({
  studentId: z.string().uuid(),
  matiere: z.string().min(1),
  modePref: z.nativeEnum(ModePref),
  notes: z.string().optional(),
});

export const listDemandesQuerySchema = z.object({
  status: z.nativeEnum(DemandeStatus).optional(),
});

export const assignerSchema = z.object({
  professeurId: z.string().uuid(),
});

// Non documente explicitement dans API_CONTRACT.md pour PATCH /demandes/:id/confirmer (le body
// n'est pas precise) : on accepte une date optionnelle pour la premiere Seance creee, avec
// aujourd'hui comme valeur par defaut si absente. Voir README/rapport pour la justification.
export const confirmerSchema = z
  .object({
    dateSeance: z.coerce.date().optional(),
  })
  .optional();

// Suivi de paiement manuel (ADMIN) — voir commentaire sur Demande.paye dans schema.prisma.
export const updatePaiementSchema = z.object({
  paye: z.boolean(),
  montant: z.number().int().nonnegative().optional(),
});
