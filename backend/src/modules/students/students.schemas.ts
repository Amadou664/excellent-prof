import { z } from "zod";
import { Niveau, Programme } from "@prisma/client";

export const createStudentSchema = z.object({
  nom: z.string().min(1),
  prenom: z.string().min(1),
  dateNaissance: z.coerce.date(),
  niveau: z.nativeEnum(Niveau),
  programme: z.nativeEnum(Programme),
});

export const updateStudentSchema = z.object({
  nom: z.string().min(1).optional(),
  prenom: z.string().min(1).optional(),
  dateNaissance: z.coerce.date().optional(),
  niveau: z.nativeEnum(Niveau).optional(),
  programme: z.nativeEnum(Programme).optional(),
});
