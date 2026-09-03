import { z } from "zod";
import { Niveau, Programme } from "@prisma/client";

// Roles auto-attribuables a l'inscription. ADMIN est volontairement exclu : un compte admin ne
// peut pas etre cree via /auth/register (il doit etre provisionne autrement, ex: seed/console).
export const RegisterRole = z.enum(["PARENT", "PROFESSEUR", "ETUDIANT", "PARTICULIER"]);

export const registerSchema = z.object({
  role: RegisterRole,
  nom: z.string().min(1),
  prenom: z.string().min(1),
  telephone: z.string().min(1),
  ville: z.string().min(1),
  teacherProfile: z
    .object({
      specialites: z.array(z.string()).default([]),
      bio: z.string().default(""),
      diplomesUrls: z.array(z.string()).default([]),
    })
    .optional(),
  studentSelf: z
    .object({
      niveau: z.nativeEnum(Niveau),
      programme: z.nativeEnum(Programme),
      dateNaissance: z.coerce.date(),
    })
    .optional(),
});

export type RegisterInput = z.infer<typeof registerSchema>;

export const fcmTokenSchema = z.object({
  token: z.string().min(1),
});
