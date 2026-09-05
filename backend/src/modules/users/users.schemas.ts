import { z } from "zod";
import { Role, UserStatus } from "@prisma/client";

export const listUsersQuerySchema = z.object({
  role: z.nativeEnum(Role).optional(),
  status: z.nativeEnum(UserStatus).optional(),
  q: z.string().optional(),
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
});

export const updateUserStatusSchema = z.object({
  status: z.nativeEnum(UserStatus),
});

// Auto-edition de profil : email/role/status restent exclusivement geres par Firebase Auth /
// l'ADMIN, jamais modifiables par l'utilisateur lui-meme.
export const updateMeSchema = z.object({
  photoUrl: z.string().url().optional(),
  telephone: z.string().min(1).optional(),
  ville: z.string().min(1).optional(),
  nom: z.string().min(1).optional(),
  prenom: z.string().min(1).optional(),
});
