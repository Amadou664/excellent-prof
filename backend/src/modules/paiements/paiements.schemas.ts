import { z } from "zod";

export const initierPaiementSchema = z.object({
  demandeId: z.string().uuid(),
});
