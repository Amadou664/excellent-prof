import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as activityController from "./activity.controller";

const router = Router();

router.use(verifyFirebaseToken);

// Le journal complet n'est visible que par l'ADMIN ; enregistrer une vue d'ecran est ouvert a
// tout utilisateur connecte (c'est sa propre navigation qu'il rapporte).
router.get("/", requireRole("ADMIN"), activityController.list);
router.post("/", activityController.recordVue);

export default router;
