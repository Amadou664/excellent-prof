import { getFirebaseMessaging } from "../config/firebaseAdmin";
import { prisma } from "../config/prisma";

/**
 * Envoi "best effort" d'une notification push a un utilisateur via son
 * `User.fcmToken`. N'echoue jamais l'action metier qui l'a declenchee : un
 * token absent/perime, ou Firebase Admin non configure, sont simplement
 * ignores (logges) plutot que de faire remonter une erreur a l'appelant.
 */
export async function sendPushToUser(userId: string, title: string, body: string): Promise<void> {
  try {
    const user = await prisma.user.findUnique({ where: { id: userId }, select: { fcmToken: true } });
    if (!user?.fcmToken) return;

    await getFirebaseMessaging().send({
      token: user.fcmToken,
      notification: { title, body },
    });
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("Echec envoi notification push:", err);
  }
}
