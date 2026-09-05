import { Router } from "express";
import { verifyFirebaseToken } from "../../middleware/auth";
import * as notificationsController from "./notifications.controller";

const router = Router();

router.use(verifyFirebaseToken);

router.get("/mine", notificationsController.listMine);
router.patch("/read-all", notificationsController.markAllRead);
router.patch("/:id/read", notificationsController.markRead);

export default router;
