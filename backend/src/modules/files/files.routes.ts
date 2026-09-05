import { Router } from "express";
import multer, { FileFilterCallback } from "multer";
import { Request } from "express";
import rateLimit from "express-rate-limit";
import { ApiError } from "../../utils/apiError";
import * as filesController from "./files.controller";

const ALLOWED_MIME_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/heic",
  "application/pdf",
]);

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req: Request, file, cb: FileFilterCallback) => {
    if (!ALLOWED_MIME_TYPES.has(file.mimetype)) {
      cb(ApiError.badRequest("Type de fichier non autorise (images ou PDF uniquement)", "INVALID_FILE_TYPE"));
      return;
    }
    cb(null, true);
  },
});

// Limite dediee a l'upload (remplissage du quota Neon Postgres, 0.5 Go sur le palier gratuit) :
// ne s'applique pas au GET de lecture, servi avec un cache navigateur/CDN d'un an.
const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  limit: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: { code: "RATE_LIMITED", message: "Trop d'envois de fichiers. Reessayez plus tard." } },
});

const router = Router();

// Public et non authentifie (utilise notamment pendant l'inscription enseignant, avant qu'un
// token Firebase n'existe). Taille/type limites ci-dessus pour reduire les abus.
router.post("/", uploadLimiter, upload.single("file"), filesController.upload);
router.get("/:id", filesController.serve);

export default router;
