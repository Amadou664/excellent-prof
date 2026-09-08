import { describe, expect, it, vi } from "vitest";
import type { Request, Response } from "express";
import { prismaMock } from "../../test/setup";
import { serve } from "./files.controller";

vi.mock("../../middleware/auth", () => ({
  decodeBearerToken: vi.fn(),
}));

import { decodeBearerToken } from "../../middleware/auth";

function makeRes() {
  return {
    set: vi.fn(),
    send: vi.fn(),
  } as unknown as Response;
}

function makeReq(id = "fichier-1"): Request {
  return { params: { id }, headers: {} } as unknown as Request;
}

// `serve` est exporte via `asyncHandler`, dont le wrapper ne renvoie pas la promesse interne
// (fire-and-forget + .catch(next)) : `await serve(...)` seul ne garantit donc pas que le travail
// async interne soit termine. On laisse la boucle d'evenements vider microtaches + une tache pour
// laisser les `await` chaines (findUnique, decodeBearerToken...) se resoudre avant d'asserter.
function flush() {
  return new Promise((resolve) => setTimeout(resolve, 0));
}

function makeFichier(overrides: Record<string, unknown> = {}) {
  return {
    id: "fichier-1",
    filename: "photo.jpg",
    mimeType: "image/jpeg",
    data: Buffer.from("fake"),
    sensible: false,
    createdAt: new Date(),
    ...overrides,
  };
}

describe("GET /files/:id (serve)", () => {
  it("sert un fichier non sensible sans aucune authentification", async () => {
    prismaMock.fichier.findUnique.mockResolvedValue(makeFichier() as never);
    const res = makeRes();
    const next = vi.fn();

    await serve(makeReq(), res, next);
    await flush();

    expect(res.send).toHaveBeenCalled();
    expect(next).not.toHaveBeenCalled();
    expect(decodeBearerToken).not.toHaveBeenCalled();
  });

  it("refuse un fichier sensible sans token", async () => {
    prismaMock.fichier.findUnique.mockResolvedValue(makeFichier({ sensible: true }) as never);
    vi.mocked(decodeBearerToken).mockRejectedValue(new Error("no token"));
    const res = makeRes();
    const next = vi.fn();

    await serve(makeReq(), res, next);
    await flush();

    expect(res.send).not.toHaveBeenCalled();
    expect(next).toHaveBeenCalledWith(expect.objectContaining({ status: 401 }));
  });

  it("refuse un fichier sensible a un utilisateur authentifie non-admin", async () => {
    prismaMock.fichier.findUnique.mockResolvedValue(makeFichier({ sensible: true }) as never);
    vi.mocked(decodeBearerToken).mockResolvedValue({ uid: "fb-1" } as never);
    prismaMock.user.findUnique.mockResolvedValue({ id: "u1", role: "PARENT" } as never);
    const res = makeRes();
    const next = vi.fn();

    await serve(makeReq(), res, next);
    await flush();

    expect(res.send).not.toHaveBeenCalled();
    expect(next).toHaveBeenCalledWith(expect.objectContaining({ status: 403 }));
  });

  it("sert un fichier sensible a un admin authentifie", async () => {
    prismaMock.fichier.findUnique.mockResolvedValue(makeFichier({ sensible: true }) as never);
    vi.mocked(decodeBearerToken).mockResolvedValue({ uid: "fb-admin" } as never);
    prismaMock.user.findUnique.mockResolvedValue({ id: "admin-1", role: "ADMIN" } as never);
    const res = makeRes();
    const next = vi.fn();

    await serve(makeReq(), res, next);
    await flush();

    expect(res.send).toHaveBeenCalled();
    expect(next).not.toHaveBeenCalled();
  });
});
