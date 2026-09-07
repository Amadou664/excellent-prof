import { z } from "zod";

// La cible du signalement (l'autre participant de la conversation) est deduite cote serveur a
// partir de demandeId + de l'auteur, plutot que fournie par le client : plus simple pour l'app
// (elle n'a pas besoin de connaitre l'id exact de l'autre personne), et impossible a falsifier.
export const createSignalementSchema = z.object({
  demandeId: z.string().uuid(),
  motif: z.string().min(5).max(1000),
});
