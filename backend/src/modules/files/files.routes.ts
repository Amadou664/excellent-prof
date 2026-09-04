import { Router } from "express";
import multer, { FileFilterCallback } from "multer";
import { Request } from "express";
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

const router = Router();

// Public et non authentifie (utilise notamment pendant l'inscription enseignant, avant qu'un
// token Firebase n'existe). Taille/type limites ci-dessus pour reduire les abus.
router.post("/", upload.single("file"), filesController.upload);
router.get("/:id", filesController.serve);

export default router;
