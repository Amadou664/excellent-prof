import { describe, expect, it } from "vitest";
import type { User } from "@prisma/client";
import { prismaMock } from "../../test/setup";
import { refuser } from "./demandes.service";

function makeUser(overrides: Partial<User> = {}): User {
  return {
    id: "prof-1",
    firebaseUid: "fb-1",
    email: "prof@a.com",
    telephone: "70000000",
    nom: "Traore",
    prenom: "Awa",
    role: "PROFESSEUR",
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
    status: "PROF_PROPOSE",
    notes: null,
    montant: null,
    paye: false,
    professeurId: "prof-1",
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

describe("refuser", () => {
  it("remet la demande a NOUVELLE et libere le professeur", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);
    prismaMock.demande.update.mockResolvedValue(
      makeDemande({ status: "NOUVELLE", professeurId: null }) as never
    );
    prismaMock.user.findMany.mockResolvedValue([] as never);

    await refuser("demande-1", makeUser());

    expect(prismaMock.demande.update).toHaveBeenCalledWith({
      where: { id: "demande-1" },
      data: { status: "NOUVELLE", professeurId: null },
    });
  });

  it("notifie tous les admins du refus", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);
    prismaMock.demande.update.mockResolvedValue(
      makeDemande({ status: "NOUVELLE", professeurId: null }) as never
    );
    prismaMock.user.findMany.mockResolvedValue([
      { id: "admin-1" },
      { id: "admin-2" },
    ] as never);

    await refuser("demande-1", makeUser());

    expect(prismaMock.notification.create).toHaveBeenCalledTimes(2);
  });

  it("refuse si l'appelant n'est pas le professeur assigne", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(makeDemande({ professeurId: "autre-prof" }) as never);

    await expect(refuser("demande-1", makeUser())).rejects.toMatchObject({ status: 403 });
    expect(prismaMock.demande.update).not.toHaveBeenCalled();
  });

  it("refuse si la demande n'est plus PROF_PROPOSE", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(makeDemande({ status: "CONFIRMEE" }) as never);

    await expect(refuser("demande-1", makeUser())).rejects.toMatchObject({ status: 409 });
    expect(prismaMock.demande.update).not.toHaveBeenCalled();
  });

  it("refuse quand la demande n'existe pas", async () => {
    prismaMock.demande.findUnique.mockResolvedValue(null);

    await expect(refuser("inconnue", makeUser())).rejects.toMatchObject({ status: 404 });
  });
});
