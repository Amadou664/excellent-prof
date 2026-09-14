import { describe, expect, it } from "vitest";
import type { User } from "@prisma/client";
import { prismaMock } from "../../test/setup";
import { createMessage, listMessages } from "./messages.service";

function makeUser(overrides: Partial<User> = {}): User {
  return {
    id: "user-1",
    firebaseUid: "fb-1",
    email: "a@a.com",
    telephone: "70000000",
    nom: "Traore",
    prenom: "Awa",
    role: "PARENT",
    status: "ACTIF",
    ville: "Bamako",
    photoUrl: null,
    fcmToken: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  } as User;
}

function makeDemande(overrides: Record<string, unknown> = {}) {
  return {
    id: "demande-1",
    studentId: "student-1",
    matiere: "Maths",
    modePref: "DOMICILE",
    status: "CONFIRMEE",
    notes: null,
    montant: null,
    paye: false,
    professeurId: "prof-1",
    createdAt: new Date(),
    updatedAt: new Date(),
    student: { id: "student-1", parentId: "user-1", userId: null },
    ...overrides,
  };
}

describe("createMessage — acces conditionne au paiement", () => {
  it("bloque la famille tant que le prix fixe n'est pas paye", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ montant: 25000, paye: false }) as never
    );

    await expect(
      createMessage("demande-1", makeUser({ id: "user-1", role: "PARENT" }), {
        contenu: "Bonjour",
      })
    ).rejects.toMatchObject({ status: 409, code: "PAIEMENT_REQUIS" });

    expect(prismaMock.message.create).not.toHaveBeenCalled();
  });

  it("bloque aussi le professeur tant que ce n'est pas paye", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ montant: 25000, paye: false }) as never
    );

    await expect(
      createMessage("demande-1", makeUser({ id: "prof-1", role: "PROFESSEUR" }), {
        contenu: "Bonjour",
      })
    ).rejects.toMatchObject({ status: 409, code: "PAIEMENT_REQUIS" });
  });

  it("autorise une fois le paiement confirme", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ montant: 25000, paye: true }) as never
    );
    prismaMock.message.create.mockResolvedValue({
      id: "msg-1",
      demandeId: "demande-1",
      auteurId: "user-1",
      contenu: "Bonjour",
      createdAt: new Date(),
    } as never);
    prismaMock.user.findUnique.mockResolvedValue(null);

    await expect(
      createMessage("demande-1", makeUser({ id: "user-1", role: "PARENT" }), {
        contenu: "Bonjour",
      })
    ).resolves.toMatchObject({ id: "msg-1" });
  });

  it("autorise quand aucun prix n'a encore ete fixe (montant null)", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ montant: null, paye: false }) as never
    );
    prismaMock.message.create.mockResolvedValue({
      id: "msg-2",
      demandeId: "demande-1",
      auteurId: "user-1",
      contenu: "Bonjour",
      createdAt: new Date(),
    } as never);
    prismaMock.user.findUnique.mockResolvedValue(null);

    await expect(
      createMessage("demande-1", makeUser({ id: "user-1", role: "PARENT" }), {
        contenu: "Bonjour",
      })
    ).resolves.toMatchObject({ id: "msg-2" });
  });

  it("l'ADMIN passe toujours, meme sans paiement", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ montant: 25000, paye: false }) as never
    );
    prismaMock.message.create.mockResolvedValue({
      id: "msg-3",
      demandeId: "demande-1",
      auteurId: "admin-1",
      contenu: "Bonjour",
      createdAt: new Date(),
    } as never);

    await expect(
      createMessage("demande-1", makeUser({ id: "admin-1", role: "ADMIN" }), {
        contenu: "Bonjour",
      })
    ).resolves.toMatchObject({ id: "msg-3" });
  });
});

describe("listMessages — acces conditionne au paiement", () => {
  it("bloque la lecture tant que ce n'est pas paye", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ montant: 25000, paye: false }) as never
    );

    await expect(
      listMessages("demande-1", makeUser({ id: "user-1", role: "PARENT" }))
    ).rejects.toMatchObject({ status: 409, code: "PAIEMENT_REQUIS" });
  });

  it("autorise la lecture une fois paye", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ montant: 25000, paye: true }) as never
    );
    prismaMock.message.findMany.mockResolvedValue([] as never);

    await expect(
      listMessages("demande-1", makeUser({ id: "user-1", role: "PARENT" }))
    ).resolves.toEqual([]);
  });
});
