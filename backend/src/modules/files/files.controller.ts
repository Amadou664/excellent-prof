import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import * as filesService from "./files.service";

/**
 * Le `mimetype` fourni par multer vient de l'en-tete Content-Type declare par le client, donc
 * falsifiable (ex: envoyer un fichier HTML/script en pretendant que c'est un "image/png"). On
 * verifie ici les premiers octets ("magic bytes") du fichier reellement recu pour les formats
 * qu'on peut facilement authentifier ; HEIC (conteneur ISOBMFF plus complexe) n'est pas verifie
 * ici et reste couvert par les en-tetes anti-sniffing (Helmet) + la restriction de type a l'upload.
 */
function matchesDeclaredType(buffer: Buffer, mimetype: string): boolean {
  const bytes = buffer.subarray(0, 12);
  switch (mimetype) {
    case "image/png":
      return bytes.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
    case "image/jpeg":
      return bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
    case "image/webp":
      return bytes.subarray(0, 4).toString("ascii") === "RIFF" && bytes.subarray(8, 12).toString("ascii") === "WEBP";
    case "application/pdf":
      return bytes.subarray(0, 4).toString("ascii") === "%PDF";
    default:
      // Type non couvert par une signature connue (ex: HEIC) : on ne bloque pas, deja filtre par
      // ailleurs.
      return true;
  }
}

export const upload = asyncHandler(async (req: Request, res: Response) => {
  if (!req.file) {
    throw ApiError.badRequest("Aucun fichier recu (champ 'file' attendu)", "NO_FILE");
  }
  if (!matchesDeclaredType(req.file.buffer, req.file.mimetype)) {
    throw ApiError.badRequest(
      "Le contenu du fichier ne correspond pas au type declare",
      "FILE_TYPE_MISMATCH"
    );
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
