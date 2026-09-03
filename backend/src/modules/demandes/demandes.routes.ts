import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as demandesController from "./demandes.controller";

const router = Router();

router.use(verifyFirebaseToken);

router.post(
  "/",
  requireRole("PARENT", "ETUDIANT", "PARTICULIER"),
  demandesController.create
);
router.get("/mine", demandesController.getMine);
router.get("/", requireRole("ADMIN"), demandesController.list);
router.patch("/:id/assigner", requireRole("ADMIN"), demandesController.assigner);
router.patch("/:id/confirmer", requireRole("PROFESSEUR"), demandesController.confirmer);
// Annulation : proprietaire (parent/etudiant/particulier proprietaire de l'eleve) ou ADMIN —
// verifie dans demandes.service.annuler.
router.patch("/:id/annuler", demandesController.annuler);

export default router;
