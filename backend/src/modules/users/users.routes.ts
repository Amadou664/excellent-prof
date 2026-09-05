import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as usersController from "./users.controller";

const router = Router();

// Auto-edition de son propre profil (avant le gate ADMIN ci-dessous, qui ne s'applique qu'aux
// routes de gestion des AUTRES utilisateurs).
router.patch("/me", verifyFirebaseToken, usersController.updateMe);

router.use(verifyFirebaseToken, requireRole("ADMIN"));

router.get("/", usersController.list);
router.get("/:id", usersController.getDetail);
router.patch("/:id/status", usersController.updateStatus);

export default router;
