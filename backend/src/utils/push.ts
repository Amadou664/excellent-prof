import { getFirebaseMessaging } from "../config/firebaseAdmin";
import { prisma } from "../config/prisma";

/**
 * Notifie un utilisateur : persiste toujours une `Notification` (centre de
 * notifications dans l'app, consultable meme hors ligne ou apres balayage de
 * la notification systeme), et tente en plus un push FCM "best effort" si un
 * `fcmToken` est connu. Le push peut echouer silencieusement (token perime,
 * Firebase Admin non configure...) sans jamais faire remonter d'erreur a
 * l'appelant : seule la persistance en base est consideree essentielle.
 */
export async function sendPushToUser(userId: string, title: string, body: string): Promise<void> {
  try {
    await prisma.notification.create({
      data: { userId, titre: title, corps: body },
    });
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("Echec enregistrement notification:", err);
  }

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
