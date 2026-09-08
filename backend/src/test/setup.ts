import { beforeEach, vi } from "vitest";
import { mockDeep, mockReset, type DeepMockProxy } from "vitest-mock-extended";
import type { PrismaClient } from "@prisma/client";

// Mock Prisma partage par tous les tests : aucun test unitaire ne doit jamais toucher la vraie
// base de donnees (Neon, la meme en local et en production — pas de base de test separee, voir
// README). `vi.mock` resout le chemin relatif a CE fichier, mais s'applique globalement a tout
// import de src/config/prisma.ts, quel que soit le chemin relatif utilise par le fichier de test.
export const prismaMock = mockDeep<PrismaClient>();

vi.mock("../config/prisma", () => ({
  prisma: prismaMock,
  default: prismaMock,
}));

beforeEach(() => {
  mockReset(prismaMock);
});

export type { DeepMockProxy };
