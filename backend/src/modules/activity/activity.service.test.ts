import { describe, expect, it } from "vitest";
import { prismaMock } from "../../test/setup";
import { list, record, recordVue } from "./activity.service";

describe("record", () => {
  it("enregistre une ligne du journal", async () => {
    prismaMock.activityLog.create.mockResolvedValue({} as never);

    await record({ userId: "user-1", method: "POST", path: "/api/demandes", statusCode: 201 });

    expect(prismaMock.activityLog.create).toHaveBeenCalledWith({
      data: {
        userId: "user-1",
        role: undefined,
        method: "POST",
        path: "/api/demandes",
        statusCode: 201,
      },
    });
  });

  it("ignore silencieusement les verifications de sante", async () => {
    await record({ method: "GET", path: "/health", statusCode: 200 });

    expect(prismaMock.activityLog.create).not.toHaveBeenCalled();
  });

  it("ne fait jamais echouer l'appelant si l'ecriture echoue", async () => {
    prismaMock.activityLog.create.mockRejectedValue(new Error("DB indisponible"));

    await expect(
      record({ method: "GET", path: "/api/annonces", statusCode: 200 })
    ).resolves.toBeUndefined();
  });
});

describe("recordVue", () => {
  it("enregistre une vue d'ecran avec la methode VUE", async () => {
    prismaMock.activityLog.create.mockResolvedValue({} as never);

    await recordVue("user-1", "PARENT", "/parent/dashboard");

    expect(prismaMock.activityLog.create).toHaveBeenCalledWith({
      data: {
        userId: "user-1",
        role: "PARENT",
        method: "VUE",
        path: "/parent/dashboard",
        statusCode: undefined,
      },
    });
  });
});

describe("list", () => {
  it("filtre par utilisateur quand demande", async () => {
    prismaMock.activityLog.findMany.mockResolvedValue([] as never);

    await list({ limit: 50, userId: "user-1" });

    expect(prismaMock.activityLog.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: { userId: "user-1" } })
    );
  });

  it("met en forme chaque ligne", async () => {
    prismaMock.activityLog.findMany.mockResolvedValue([
      {
        id: "log-1",
        userId: "user-1",
        role: null,
        method: "POST",
        path: "/api/demandes",
        statusCode: 201,
        createdAt: new Date("2026-09-14T10:00:00.000Z"),
        user: { nom: "Traore", prenom: "Awa", role: "PARENT" },
      },
    ] as never);

    const result = await list({ limit: 50 });

    expect(result).toEqual([
      {
        id: "log-1",
        userId: "user-1",
        utilisateur: "Awa Traore",
        role: "PARENT",
        method: "POST",
        path: "/api/demandes",
        statusCode: 201,
        createdAt: "2026-09-14T10:00:00.000Z",
      },
    ]);
  });
});
