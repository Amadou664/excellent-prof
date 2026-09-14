import { z } from "zod";

export const recordVueSchema = z.object({
  ecran: z.string().min(1).max(200),
});

export const listActivityQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(200).default(50),
  cursor: z.string().optional(),
  userId: z.string().optional(),
});
