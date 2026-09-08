import { describe, expect, it } from "vitest";
import type { User } from "@prisma/client";
import { prismaMock } from "../../test/setup";
import { createSignalement, markTraite } from "./signalements.service";

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

describe("createSignalement", () => {
  it("resout la cible sur le professeur quand l'auteur est la famille", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);
    prismaMock.signalement.create.mockResolvedValue({
      id: "s1",
      auteurId: "user-1",
      cibleId: "prof-1",
      demandeId: "demande-1",
      motif: "Comportement inapproprie",
      statut: "NOUVEAU",
      createdAt: new Date(),
    } as never);
    prismaMock.user.findMany.mockResolvedValue([] as never);

    await createSignalement(makeUser({ id: "user-1" }), {
      demandeId: "demande-1",
      motif: "Comportement inapproprie",
    });

    expect(prismaMock.signalement.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ auteurId: "user-1", cibleId: "prof-1" }),
    });
  });

  it("resout la cible sur la famille quand l'auteur est le professeur", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);
    prismaMock.signalement.create.mockResolvedValue({
      id: "s2",
      auteurId: "prof-1",
      cibleId: "user-1",
      demandeId: "demande-1",
      motif: "Demande de paiement suspecte",
      statut: "NOUVEAU",
      createdAt: new Date(),
    } as never);
    prismaMock.user.findMany.mockResolvedValue([] as never);

    await createSignalement(makeUser({ id: "prof-1" }), {
      demandeId: "demande-1",
      motif: "Demande de paiement suspecte",
    });

    expect(prismaMock.signalement.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ auteurId: "prof-1", cibleId: "user-1" }),
    });
  });

  it("refuse un utilisateur qui n'est ni la famille ni le professeur de la demande", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);

    await expect(
      createSignalement(makeUser({ id: "etranger-1" }), {
        demandeId: "demande-1",
        motif: "Peu importe",
      })
    ).rejects.toMatchObject({ status: 403 });

    expect(prismaMock.signalement.create).not.toHaveBeenCalled();
  });

  it("refuse quand la demande n'existe pas", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(null);

    await expect(
      createSignalement(makeUser(), { demandeId: "inconnue", motif: "Peu importe" })
    ).rejects.toMatchObject({ status: 404 });
  });

  it("renvoie un conflit si aucun autre participant n'est encore assigne", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(
      makeDemande({ professeurId: null }) as never
    );

    await expect(
      createSignalement(makeUser({ id: "user-1" }), {
        demandeId: "demande-1",
        motif: "Peu importe",
      })
    ).rejects.toMatchObject({ status: 409, code: "NO_CIBLE" });

    expect(prismaMock.signalement.create).not.toHaveBeenCalled();
  });
});

describe("markTraite", () => {
  it("refuse un signalement introuvable", async () => {
    prismaMock.signalement.findUnique.mockResolvedValue(null);

    await expect(markTraite("inconnu")).rejects.toMatchObject({ status: 404 });
    expect(prismaMock.signalement.update).not.toHaveBeenCalled();
  });
});
