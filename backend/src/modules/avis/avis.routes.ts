import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as avisController from "./avis.controller";

const router = Router();

router.use(verifyFirebaseToken);

router.post(
  "/",
  requireRole("PARENT", "ETUDIANT", "PARTICULIER"),
  avisController.create
);
router.get("/", avisController.list);
router.patch("/:id/statut", requireRole("ADMIN"), avisController.updateStatut);
router.delete("/:id", requireRole("ADMIN"), avisController.remove);

export default router;
