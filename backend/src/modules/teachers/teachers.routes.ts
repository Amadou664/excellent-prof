import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as teachersController from "./teachers.controller";

const router = Router();

router.use(verifyFirebaseToken);

router.get("/me", requireRole("PROFESSEUR"), teachersController.getMe);
router.patch("/me", requireRole("PROFESSEUR"), teachersController.updateMe);

router.get("/", requireRole("ADMIN"), teachersController.list);
router.patch("/:id/candidature", requireRole("ADMIN"), teachersController.updateCandidature);

export default router;
