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
