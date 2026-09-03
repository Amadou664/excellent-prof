import { Router } from "express";
import { verifyFirebaseToken, requireRole } from "../../middleware/auth";
import * as studentsController from "./students.controller";

const router = Router();

router.use(verifyFirebaseToken);

router.get("/mine", studentsController.getMine);
router.post("/", requireRole("PARENT"), studentsController.create);
router.patch("/:id", studentsController.update);
router.delete("/:id", studentsController.remove);

export default router;
