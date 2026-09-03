import { PrismaClient } from "@prisma/client";

// Client Prisma singleton — evite d'ouvrir un nouveau pool de connexions a chaque hot-reload
// en dev (ts-node-dev) et a chaque import ailleurs dans l'app.
declare global {
  // eslint-disable-next-line no-var
  var __prisma__: PrismaClient | undefined;
}

export const prisma =
  global.__prisma__ ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  global.__prisma__ = prisma;
}

export default prisma;
