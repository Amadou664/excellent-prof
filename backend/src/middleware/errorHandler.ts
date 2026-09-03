import { NextFunction, Request, Response } from "express";
import { Prisma } from "@prisma/client";
import { ZodError } from "zod";
import { ApiError } from "../utils/apiError";

/**
 * Middleware d'erreur unique, monte en dernier dans src/index.ts. Toute erreur transmise via
 * `next(err)` (ou levee dans un handler enveloppe par asyncHandler) atterrit ici et ressort au
 * format `{ error: { code, message } }` avec le statut HTTP approprie.
 */
// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof ApiError) {
    return res.status(err.status).json({ error: { code: err.code, message: err.message } });
  }

  if (err instanceof ZodError) {
    const message = err.issues
      .map((issue) => `${issue.path.join(".") || "body"}: ${issue.message}`)
      .join("; ");
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message } });
  }

  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === "P2002") {
      return res.status(409).json({
        error: { code: "UNIQUE_CONSTRAINT", message: "Cette ressource existe deja." },
      });
    }
    if (err.code === "P2025") {
      return res.status(404).json({
        error: { code: "NOT_FOUND", message: "Ressource introuvable." },
      });
    }
  }

  // eslint-disable-next-line no-console
  console.error(err);
  return res
    .status(500)
    .json({ error: { code: "INTERNAL_ERROR", message: "Erreur interne du serveur." } });
}
