import { Router } from "express";
import rateLimit from "express-rate-limit";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as signalementsController from "./signalements.controller";

const router = Router();

router.use(verifyFirebaseToken);

// Limite raisonnable pour eviter le spam de signalements, sans jamais gener un usage normal
// (un vrai probleme a signaler ne se reproduit pas 10 fois par heure).
router.post(
  "/",
  rateLimit({
    windowMs: 60 * 60 * 1000,
    limit: 10,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: { code: "RATE_LIMITED", message: "Trop de signalements. Reessayez plus tard." } },
  }),
  signalementsController.create
);

router.get("/", requireRole("ADMIN"), signalementsController.list);
router.patch("/:id/traiter", requireRole("ADMIN"), signalementsController.markTraite);

export default router;
