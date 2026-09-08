import { Router } from "express";
import rateLimit from "express-rate-limit";
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

// Chaque appel reussi cree une tentative CinetPay reelle : on limite pour eviter qu'un client
// buggue (ou malveillant) n'en spamme la creation, sans jamais gener un usage normal (personne ne
// tente legitimement de payer 30 fois par heure la meme chose).
router.post(
  "/initier",
  rateLimit({
    windowMs: 60 * 60 * 1000,
    limit: 30,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: { code: "RATE_LIMITED", message: "Trop de tentatives. Reessayez plus tard." } },
  }),
  paiementsController.initier
);
router.get("/:demandeId/statut", paiementsController.statut);
router.get("/", requireRole("ADMIN"), paiementsController.listAll);

export default router;
