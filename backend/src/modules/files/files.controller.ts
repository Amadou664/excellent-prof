import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import * as filesService from "./files.service";

export const upload = asyncHandler(async (req: Request, res: Response) => {
  if (!req.file) {
    throw ApiError.badRequest("Aucun fichier recu (champ 'file' attendu)", "NO_FILE");
  }
  const id = await filesService.createFichier(
    req.file.originalname,
    req.file.mimetype,
    req.file.buffer
  );
  const url = `${req.protocol}://${req.get("host")}/api/files/${id}`;
  res.status(201).json({ data: { id, url } });
});

export const serve = asyncHandler(async (req: Request, res: Response) => {
  const fichier = await filesService.getFichier(req.params.id);
  res.set("Content-Type", fichier.mimeType);
  res.set("Cache-Control", "public, max-age=31536000, immutable");
  res.send(fichier.data);
});
