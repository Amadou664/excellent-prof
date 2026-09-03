import { User } from "@prisma/client";

declare global {
  namespace Express {
    interface Request {
      /** Utilisateur Prisma resolu a partir du token Firebase verifie. Absent si non authentifie. */
      user?: User;
      /** Rempli uniquement par verifyFirebaseTokenOnly (POST /auth/register), avant creation du User. */
      firebaseUser?: { uid: string; email: string };
    }
  }
}

export {};
