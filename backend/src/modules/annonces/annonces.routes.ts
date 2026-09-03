import { Router } from "express";
import { optionalAuth, verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as annoncesController from "./annonces.controller";

const router = Router();

// Public, mais enrichi (annonces CONNECTES en plus de PUBLIC) si un token valide est fourni.
router.get("/", optionalAuth, annoncesController.list);

router.post(
  "/",
  verifyFirebaseToken,
  requireRole("ADMIN"),
  annoncesController.create
);
router.patch(
  "/:id",
  verifyFirebaseToken,
  requireRole("ADMIN"),
  annoncesController.update
);
router.delete(
  "/:id",
  verifyFirebaseToken,
  requireRole("ADMIN"),
  annoncesController.remove
);

export default router;
