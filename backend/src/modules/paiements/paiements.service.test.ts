import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import type { User } from "@prisma/client";
import { prismaMock } from "../../test/setup";
import { env } from "../../config/env";
import { initierPaiement, traiterWebhook } from "./paiements.service";

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
    montant: 15000,
    paye: false,
    professeurId: "prof-1",
    createdAt: new Date(),
    updatedAt: new Date(),
    student: { id: "student-1", parentId: "user-1", userId: null },
    ...overrides,
  };
}

describe("initierPaiement", () => {
  afterEach(() => {
    env.cinetpayApiKey = "";
    env.cinetpaySiteId = "";
    vi.unstubAllGlobals();
  });

  it("refuse quand CinetPay n'est pas configure", async () => {
    env.cinetpayApiKey = "";
    env.cinetpaySiteId = "";

    await expect(
      initierPaiement(makeUser(), { demandeId: "demande-1" })
    ).rejects.toMatchObject({ status: 409, code: "PAIEMENT_NON_CONFIGURE" });

    expect(prismaMock.demande.findUnique).not.toHaveBeenCalled();
  });

  describe("une fois configure", () => {
    beforeEach(() => {
      env.cinetpayApiKey = "test-key";
      env.cinetpaySiteId = "test-site";
    });

    it("refuse un utilisateur qui n'est pas le proprietaire de la demande", async () => {
      prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);

      await expect(
        initierPaiement(makeUser({ id: "etranger-1" }), { demandeId: "demande-1" })
      ).rejects.toMatchObject({ status: 403 });
    });

    it("refuse quand le montant n'a pas ete fixe", async () => {
      prismaMock.demande.findUnique.mockResolvedValue(
        makeDemande({ montant: null }) as never
      );

      await expect(
        initierPaiement(makeUser({ id: "user-1" }), { demandeId: "demande-1" })
      ).rejects.toMatchObject({ status: 409, code: "MONTANT_NON_DEFINI" });
    });

    it("refuse une demande deja payee", async () => {
      prismaMock.demande.findUnique.mockResolvedValue(
        makeDemande({ paye: true }) as never
      );

      await expect(
        initierPaiement(makeUser({ id: "user-1" }), { demandeId: "demande-1" })
      ).rejects.toMatchObject({ status: 409, code: "DEJA_PAYE" });
    });

    it("cree une tentative EN_ATTENTE et renvoie l'URL de paiement quand CinetPay repond succes", async () => {
      prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);
      prismaMock.paiement.create.mockResolvedValue({ id: "paiement-1" } as never);
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({
          json: () =>
            Promise.resolve({
              code: "201",
              data: { payment_url: "https://checkout.cinetpay.com/xyz" },
            }),
        })
      );

      const result = await initierPaiement(makeUser({ id: "user-1" }), {
        demandeId: "demande-1",
      });

      expect(result.paymentUrl).toBe("https://checkout.cinetpay.com/xyz");
      expect(prismaMock.paiement.create).toHaveBeenCalledWith({
        data: expect.objectContaining({ demandeId: "demande-1", montant: 15000, statut: "EN_ATTENTE" }),
      });
      expect(prismaMock.paiement.update).not.toHaveBeenCalled();
    });

    it("marque la tentative ECHOUE quand CinetPay ne renvoie pas d'URL de paiement", async () => {
      prismaMock.demande.findUnique.mockResolvedValue(makeDemande() as never);
      prismaMock.paiement.create.mockResolvedValue({ id: "paiement-1" } as never);
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({
          json: () => Promise.resolve({ code: "600", message: "erreur" }),
        })
      );

      await expect(
        initierPaiement(makeUser({ id: "user-1" }), { demandeId: "demande-1" })
      ).rejects.toMatchObject({ status: 500, code: "CINETPAY_ERREUR" });

      expect(prismaMock.paiement.update).toHaveBeenCalledWith({
        where: { id: "paiement-1" },
        data: { statut: "ECHOUE" },
      });
    });
  });
});

describe("traiterWebhook", () => {
  beforeEach(() => {
    env.cinetpayApiKey = "test-key";
    env.cinetpaySiteId = "test-site";
  });

  afterEach(() => {
    env.cinetpayApiKey = "";
    env.cinetpaySiteId = "";
    vi.unstubAllGlobals();
  });

  it("ne fait rien sans transactionId", async () => {
    await traiterWebhook(undefined);
    expect(prismaMock.paiement.findUnique).not.toHaveBeenCalled();
  });

  it("ne fait rien si la transaction est introuvable", async () => {
    prismaMock.paiement.findUnique.mockResolvedValue(null);
    await traiterWebhook("tx-inconnue");
    expect(prismaMock.$transaction).not.toHaveBeenCalled();
  });

  it("est idempotent : ignore un paiement deja traite (pas EN_ATTENTE)", async () => {
    prismaMock.paiement.findUnique.mockResolvedValue({
      id: "paiement-1",
      statut: "REUSSI",
    } as never);

    await traiterWebhook("tx-1");

    expect(prismaMock.$transaction).not.toHaveBeenCalled();
  });

  it("confirme le paiement et marque la demande payee quand CinetPay confirme ACCEPTED", async () => {
    prismaMock.paiement.findUnique.mockResolvedValue({
      id: "paiement-1",
      demandeId: "demande-1",
      montant: 15000,
      statut: "EN_ATTENTE",
      demande: {
        matiere: "Maths",
        professeurId: "prof-1",
        student: { parentId: "user-1", userId: null },
      },
    } as never);
    prismaMock.user.findMany.mockResolvedValue([] as never);
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        json: () =>
          Promise.resolve({ code: "00", data: { status: "ACCEPTED", payment_method: "OM" } }),
      })
    );

    await traiterWebhook("tx-1");

    expect(prismaMock.paiement.update).toHaveBeenCalledWith({
      where: { id: "paiement-1" },
      data: { statut: "REUSSI", moyenPaiement: "OM" },
    });
    expect(prismaMock.demande.update).toHaveBeenCalledWith({
      where: { id: "demande-1" },
      data: { paye: true },
    });
    expect(prismaMock.$transaction).toHaveBeenCalled();
  });

  it("marque la tentative ECHOUE quand CinetPay confirme REFUSED", async () => {
    prismaMock.paiement.findUnique.mockResolvedValue({
      id: "paiement-1",
      demandeId: "demande-1",
      montant: 15000,
      statut: "EN_ATTENTE",
      demande: {
        matiere: "Maths",
        professeurId: "prof-1",
        student: { parentId: "user-1", userId: null },
      },
    } as never);
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        json: () => Promise.resolve({ code: "00", data: { status: "REFUSED" } }),
      })
    );

    await traiterWebhook("tx-1");

    expect(prismaMock.paiement.update).toHaveBeenCalledWith({
      where: { id: "paiement-1" },
      data: { statut: "ECHOUE" },
    });
    expect(prismaMock.demande.update).not.toHaveBeenCalled();
  });

  it("ne change rien quand CinetPay renvoie PENDING", async () => {
    prismaMock.paiement.findUnique.mockResolvedValue({
      id: "paiement-1",
      demandeId: "demande-1",
      montant: 15000,
      statut: "EN_ATTENTE",
      demande: {
        matiere: "Maths",
        professeurId: "prof-1",
        student: { parentId: "user-1", userId: null },
      },
    } as never);
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        json: () => Promise.resolve({ code: "00", data: { status: "PENDING" } }),
      })
    );

    await traiterWebhook("tx-1");

    expect(prismaMock.paiement.update).not.toHaveBeenCalled();
    expect(prismaMock.demande.update).not.toHaveBeenCalled();
  });
});
