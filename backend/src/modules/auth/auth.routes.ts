import { Router } from "express";
import { verifyFirebaseToken, verifyFirebaseTokenOnly } from "../../middleware/auth";
import * as authController from "./auth.controller";

const router = Router();

// "Public" au sens ou aucun User applicatif n'existe encore, mais le token Firebase (deja
// obtenu cote client apres creation du compte Firebase Auth) reste requis pour identifier
// firebaseUid/email.
router.post("/register", verifyFirebaseTokenOnly, authController.register);

router.get("/me", verifyFirebaseToken, authController.me);
router.post("/fcm-token", verifyFirebaseToken, authController.setFcmToken);

export default router;
