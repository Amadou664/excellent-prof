import { z } from "zod";

export const createCoursSchema = z.object({
  titre: z.string().min(1),
  description: z.string().min(1),
  matiere: z.string().min(1),
  dateDebut: z.coerce.date(),
  dateFin: z.coerce.date(),
  tarif: z.number().int().nonnegative(),
  placesDisponibles: z.number().int().positive(),
});

export const updateCoursSchema = z.object({
  titre: z.string().min(1).optional(),
  description: z.string().min(1).optional(),
  matiere: z.string().min(1).optional(),
  dateDebut: z.coerce.date().optional(),
  dateFin: z.coerce.date().optional(),
  tarif: z.number().int().nonnegative().optional(),
  placesDisponibles: z.number().int().positive().optional(),
});

export const inscriptionSchema = z.object({
  studentId: z.string().uuid(),
});
