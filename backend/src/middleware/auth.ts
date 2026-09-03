import { NextFunction, Request, Response } from "express";
import { DecodedIdToken } from "firebase-admin/auth";
import { Role } from "@prisma/client";
import { getFirebaseAuth } from "../config/firebaseAdmin";
import { prisma } from "../config/prisma";
import { ApiError } from "../utils/apiError";
import { asyncHandler } from "../utils/asyncHandler";

async function decodeBearerToken(req: Request): Promise<DecodedIdToken> {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    throw ApiError.unauthorized("Header Authorization: Bearer <token> manquant");
  }
  const idToken = header.slice("Bearer ".length).trim();
  if (!idToken) {
    throw ApiError.unauthorized("Token Firebase manquant");
  }
  try {
    return await getFirebaseAuth().verifyIdToken(idToken);
  } catch (err) {
    throw ApiError.unauthorized("Token Firebase invalide ou expire");
  }
}

/**
 * Verifie le header `Authorization: Bearer <Firebase ID token>`, resout le firebaseUid via
 * Firebase Admin, puis va chercher la ligne `User` correspondante en base (creee lors de
 * `POST /auth/register`) et l'attache a `req.user`.
 *
 * Rejette avec 401 si le header est absent/mal forme, si le token est invalide/expire, ou si
 * aucun `User` ne correspond encore (le client doit d'abord appeler /auth/register).
 */
export const verifyFirebaseToken = asyncHandler(
  async (req: Request, _res: Response, next: NextFunction) => {
    const decoded = await decodeBearerToken(req);

    const user = await prisma.user.findUnique({ where: { firebaseUid: decoded.uid } });
    if (!user) {
      throw ApiError.unauthorized(
        "Aucun compte utilisateur associe a ce token. Appelez /auth/register d'abord.",
        "USER_NOT_REGISTERED"
      );
    }

    req.user = user;
    next();
  }
);

/**
 * Variante utilisee uniquement par POST /auth/register : le compte Firebase existe deja
 * (cree cote client) mais la ligne `User` cote backend n'existe pas encore. On verifie donc le
 * token et on attache `req.firebaseUser = { uid, email }` sans chercher de `User` en base.
 */
export const verifyFirebaseTokenOnly = asyncHandler(
  async (req: Request, _res: Response, next: NextFunction) => {
    const decoded = await decodeBearerToken(req);
    req.firebaseUser = { uid: decoded.uid, email: decoded.email ?? "" };
    next();
  }
);

/**
 * Middleware "best effort" pour les routes publiques qui enrichissent la reponse si
 * l'utilisateur est authentifie (ex: GET /annonces expose aussi les annonces `CONNECTES`).
 * N'echoue jamais : header absent ou token invalide -> requete traitee comme anonyme.
 */
export const optionalAuth = asyncHandler(
  async (req: Request, _res: Response, next: NextFunction) => {
    const header = req.headers.authorization;
    if (!header || !header.startsWith("Bearer ")) {
      return next();
    }
    try {
      const decoded = await decodeBearerToken(req);
      const user = await prisma.user.findUnique({ where: { firebaseUid: decoded.uid } });
      if (user) {
        req.user = user;
      }
    } catch {
      // Requete traitee comme anonyme si le token est invalide.
    }
    next();
  }
);

/**
 * A utiliser APRES verifyFirebaseToken. Refuse l'acces (403) si le role de req.user n'est pas
 * dans la liste autorisee.
 */
export function requireRole(...roles: Role[]) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(ApiError.unauthorized());
    }
    if (!roles.includes(req.user.role)) {
      return next(ApiError.forbidden(`Reserve aux roles: ${roles.join(", ")}`));
    }
    next();
  };
}
