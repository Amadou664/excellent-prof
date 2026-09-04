import { z } from "zod";

export const createMessageSchema = z.object({
  contenu: z.string().min(1).max(2000),
});
