import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as statsController from "./stats.controller";

const router = Router();

router.get("/stats", verifyFirebaseToken, requireRole("ADMIN"), statsController.getStats);

export default router;
