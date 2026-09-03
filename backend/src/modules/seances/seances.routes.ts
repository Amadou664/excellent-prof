import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as seancesController from "./seances.controller";

const router = Router();

router.use(verifyFirebaseToken);

router.get("/mine", seancesController.getMine);
router.post("/", requireRole("PROFESSEUR", "ADMIN"), seancesController.create);
// Role non precise explicitement par API_CONTRACT.md pour cette transition : restreint au
// professeur (qui anime la seance) et a l'ADMIN, par coherence avec POST /seances.
router.patch(
  "/:id/statut",
  requireRole("PROFESSEUR", "ADMIN"),
  seancesController.updateStatut
);
router.put("/:id/cahier-texte", requireRole("PROFESSEUR"), seancesController.putCahierTexte);
router.get("/:id/cahier-texte", seancesController.getCahierTexte);

export default router;
