import { User } from "@prisma/client";
import { randomUUID } from "crypto";
import { z } from "zod";
import { env } from "../../config/env";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { sendPushToUser } from "../../utils/push";
import { initierPaiementSchema } from "./paiements.schemas";

const CINETPAY_BASE_URL = "https://api-checkout.cinetpay.com/v2";

function assertConfigured() {
  if (!env.cinetpayApiKey || !env.cinetpaySiteId) {
    throw ApiError.conflict(
      "Le paiement en ligne n'est pas encore active sur cette plateforme. Contactez l'administrateur.",
      "PAIEMENT_NON_CONFIGURE"
    );
  }
}

async function getDemandeForPaiement(demandeId: string, user: User) {
  const demande = await prisma.demande.findUnique({
    where: { id: demandeId },
    include: { student: true },
  });
  if (!demande) throw ApiError.notFound("Demande introuvable");

  const familyOwnerId = demande.student.parentId ?? demande.student.userId;
  const isOwner = familyOwnerId === user.id;
  if (!isOwner && user.role !== "ADMIN") {
    throw ApiError.forbidden("Cette demande ne vous appartient pas");
  }
  if (!demande.montant) {
    throw ApiError.conflict(
      "Le montant de cette demande n'a pas encore ete fixe par l'administrateur.",
      "MONTANT_NON_DEFINI"
    );
  }
  if (demande.paye) {
    throw ApiError.conflict("Cette demande est deja payee.", "DEJA_PAYE");
  }
  return demande;
}

export async function initierPaiement(
  user: User,
  body: z.infer<typeof initierPaiementSchema>
) {
  assertConfigured();
  const demande = await getDemandeForPaiement(body.demandeId, user);

  const transactionId = `ep-${demande.id.slice(0, 8)}-${randomUUID().slice(0, 8)}`;

  const paiement = await prisma.paiement.create({
    data: {
      demandeId: demande.id,
      transactionId,
      montant: demande.montant!,
      statut: "EN_ATTENTE",
    },
  });

  const response = await fetch(`${CINETPAY_BASE_URL}/payment`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      apikey: env.cinetpayApiKey,
      site_id: env.cinetpaySiteId,
      transaction_id: transactionId,
      amount: demande.montant,
      currency: "XOF",
      description: `Cours ${demande.matiere} - L'Excellent Prof`,
      customer_name: user.nom,
      customer_surname: user.prenom,
      customer_email: user.email,
      customer_phone_number: user.telephone,
      customer_country: "ML",
      notify_url: `${env.backendPublicUrl}/api/paiements/webhook`,
      return_url: `${env.webPublicUrl}/paiement-retour.html`,
      channels: "ALL",
      metadata: paiement.id,
      lang: "FR",
    }),
  });

  const json = (await response.json()) as {
    code?: string;
    message?: string;
    data?: { payment_url?: string; payment_token?: string };
  };

  if (json.code !== "201" || !json.data?.payment_url) {
    await prisma.paiement.update({ where: { id: paiement.id }, data: { statut: "ECHOUE" } });
    throw ApiError.internal(
      "Impossible de contacter le service de paiement pour le moment. Reessayez plus tard.",
      "CINETPAY_ERREUR"
    );
  }

  return { paymentUrl: json.data.payment_url, transactionId };
}

/**
 * Interroge l'API de verification CinetPay pour connaitre le vrai statut d'une transaction.
 * Ne jamais faire confiance au corps du webhook lui-meme (CinetPay ne transmet pas le statut par
 * securite, voir doc "Prepare a notification page") : c'est cet appel qui fait foi.
 */
async function verifierAupresDeCinetpay(transactionId: string) {
  const response = await fetch(`${CINETPAY_BASE_URL}/payment/check`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      apikey: env.cinetpayApiKey,
      site_id: env.cinetpaySiteId,
      transaction_id: transactionId,
    }),
  });
  return (await response.json()) as {
    code?: string;
    data?: { status?: string; payment_method?: string };
  };
}

export async function traiterWebhook(transactionId: string | undefined) {
  if (!transactionId || !env.cinetpayApiKey || !env.cinetpaySiteId) return;

  const paiement = await prisma.paiement.findUnique({
    where: { transactionId },
    include: { demande: { include: { student: true } } },
  });
  if (!paiement || paiement.statut !== "EN_ATTENTE") return;

  const verification = await verifierAupresDeCinetpay(transactionId);
  const statutCinetpay = verification.data?.status;

  if (statutCinetpay === "ACCEPTED") {
    await prisma.$transaction([
      prisma.paiement.update({
        where: { id: paiement.id },
        data: { statut: "REUSSI", moyenPaiement: verification.data?.payment_method },
      }),
      prisma.demande.update({ where: { id: paiement.demandeId }, data: { paye: true } }),
    ]);

    const familyOwnerId = paiement.demande.student.parentId ?? paiement.demande.student.userId;
    if (familyOwnerId) {
      await sendPushToUser(
        familyOwnerId,
        "Paiement confirme",
        `Votre paiement pour le cours de ${paiement.demande.matiere} a bien ete recu.`
      );
    }
    if (paiement.demande.professeurId) {
      await sendPushToUser(
        paiement.demande.professeurId,
        "Paiement recu",
        `Le paiement pour le cours de ${paiement.demande.matiere} a ete confirme.`
      );
    }
  } else if (statutCinetpay === "REFUSED") {
    await prisma.paiement.update({ where: { id: paiement.id }, data: { statut: "ECHOUE" } });
  }
  // "PENDING" ou statut inconnu : on ne change rien, un futur appel webhook confirmera.
}

export async function getStatutPaiement(demandeId: string, user: User) {
  const demande = await prisma.demande.findUnique({
    where: { id: demandeId },
    include: { student: true },
  });
  if (!demande) throw ApiError.notFound("Demande introuvable");
  const familyOwnerId = demande.student.parentId ?? demande.student.userId;
  if (familyOwnerId !== user.id && user.role !== "ADMIN") {
    throw ApiError.forbidden("Cette demande ne vous appartient pas");
  }
  return { paye: demande.paye, montant: demande.montant };
}
