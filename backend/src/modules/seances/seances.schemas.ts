import { z } from "zod";

export const createSeanceSchema = z.object({
  demandeId: z.string().uuid(),
  dateSeance: z.coerce.date(),
});

export const updateSeanceStatutSchema = z.object({
  statut: z.enum(["EFFECTUEE", "ANNULEE"]),
});

export const cahierTexteSchema = z.object({
  contenu: z.string().default(""),
  exercices: z.string().default(""),
  devoirs: z.string().default(""),
  observations: z.string().default(""),
});
