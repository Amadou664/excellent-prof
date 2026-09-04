import { User } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { sendPushToUser } from "../../utils/push";
import { toMessageResponse } from "../../utils/mappers";
import { z } from "zod";
import { createMessageSchema } from "./messages.schemas";

async function getDemandeWithParticipantsOrThrow(demandeId: string) {
  const demande = await prisma.demande.findUnique({
    where: { id: demandeId },
    include: { student: true },
  });
  if (!demande) {
    throw ApiError.notFound("Demande introuvable");
  }
  return demande;
}

function assertParticipant(
  demande: Awaited<ReturnType<typeof getDemandeWithParticipantsOrThrow>>,
  user: User
) {
  const isOwner = demande.student.parentId === user.id || demande.student.userId === user.id;
  const isProfesseur = demande.professeurId === user.id;
  if (!isOwner && !isProfesseur && user.role !== "ADMIN") {
    throw ApiError.forbidden("Vous n'etes pas participant a cette demande");
  }
}

/**
 * La messagerie n'a de sens qu'une fois qu'un professeur est associe a la
 * demande (sinon il n'y a personne en face pour repondre).
 */
function assertConversationOuverte(
  demande: Awaited<ReturnType<typeof getDemandeWithParticipantsOrThrow>>
) {
  if (!demande.professeurId) {
    throw ApiError.conflict(
      "Aucun professeur n'est encore associe a cette demande",
      "NO_PROFESSEUR_ASSIGNED"
    );
  }
}

export async function listMessages(demandeId: string, user: User) {
  const demande = await getDemandeWithParticipantsOrThrow(demandeId);
  assertParticipant(demande, user);

  const messages = await prisma.message.findMany({
    where: { demandeId },
    orderBy: { createdAt: "asc" },
  });
  return messages.map(toMessageResponse);
}

export async function createMessage(
  demandeId: string,
  user: User,
  body: z.infer<typeof createMessageSchema>
) {
  const demande = await getDemandeWithParticipantsOrThrow(demandeId);
  assertParticipant(demande, user);
  assertConversationOuverte(demande);

  const message = await prisma.message.create({
    data: { demandeId, auteurId: user.id, contenu: body.contenu },
  });

  const familyOwnerId = demande.student.parentId ?? demande.student.userId;
  const destinataireId = user.id === demande.professeurId ? familyOwnerId : demande.professeurId;
  if (destinataireId) {
    await sendPushToUser(
      destinataireId,
      "Nouveau message",
      `${user.prenom} : ${body.contenu.slice(0, 80)}`
    );
  }

  return toMessageResponse(message);
}
