import { z } from "zod";
import { StatutCandidature } from "@prisma/client";

export const updateMyTeacherProfileSchema = z.object({
  specialites: z.array(z.string()).optional(),
  bio: z.string().optional(),
  disponibilites: z.record(z.array(z.string())).optional(),
  zoneGeo: z.string().optional(),
});

export const listTeachersQuerySchema = z.object({
  statutCandidature: z.nativeEnum(StatutCandidature).optional(),
  specialite: z.string().optional(),
  ville: z.string().optional(),
});

export const updateCandidatureSchema = z.object({
  statutCandidature: z.enum(["VALIDEE", "REFUSEE", "ENTRETIEN"]),
  // Note admin sur la verification effectuee (piece d'identite controlee, reference contactee...).
  // Voir prisma/schema.prisma sur TeacherProfile.notesVerification.
  notesVerification: z.string().optional(),
});
