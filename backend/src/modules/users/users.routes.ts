import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as usersController from "./users.controller";

const router = Router();

router.use(verifyFirebaseToken, requireRole("ADMIN"));

router.get("/", usersController.list);
router.patch("/:id/status", usersController.updateStatus);

export default router;
