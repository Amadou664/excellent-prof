import { Router } from "express";
import { optionalAuth, verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as coursController from "./coursPourTous.controller";

const router = Router();

// Public (fonctionne identiquement authentifie ou non, contrairement a /annonces).
router.get("/", optionalAuth, coursController.list);

router.post("/:id/inscription", verifyFirebaseToken, coursController.inscription);

router.post("/", verifyFirebaseToken, requireRole("ADMIN"), coursController.create);
router.patch("/:id", verifyFirebaseToken, requireRole("ADMIN"), coursController.update);
router.delete("/:id", verifyFirebaseToken, requireRole("ADMIN"), coursController.remove);

export default router;
