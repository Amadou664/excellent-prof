import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as paiementsController from "./paiements.controller";

const router = Router();

// Webhook CinetPay : appele par leurs serveurs, pas par un utilisateur de l'app, donc jamais
// derriere verifyFirebaseToken. Sa securite vient de la re-verification serveur-a-serveur dans
// paiements.service.ts, pas d'une authentification sur cette route (voir doc CinetPay :
// "CinetPay will not send you the transaction status information to avoid ... man in the middle
// attacks", ils exigent un rappel a leur API de verification).
router.post("/webhook", paiementsController.webhook);
router.get("/webhook", paiementsController.webhook);

router.use(verifyFirebaseToken);
router.post("/initier", paiementsController.initier);
router.get("/:demandeId/statut", paiementsController.statut);
router.get("/", requireRole("ADMIN"), paiementsController.listAll);

export default router;
