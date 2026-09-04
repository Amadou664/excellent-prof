import admin from "firebase-admin";
import { env } from "./env";

/**
 * Initialisation paresseuse (lazy) du Firebase Admin SDK.
 *
 * Comment remplir les variables d'environnement (voir aussi README.md section 2) :
 *
 * Option A (recommandee, notamment sur Render) — FIREBASE_SERVICE_ACCOUNT_JSON :
 *   1. Console Firebase -> Parametres du projet -> Comptes de service -> "Generer une nouvelle
 *      cle privee". Un fichier `service-account.json` est telecharge.
 *   2. Encodez tout le fichier en base64 sur une seule ligne :
 *        - Linux/Mac : base64 -w0 service-account.json
 *        - PowerShell : [Convert]::ToBase64String([IO.File]::ReadAllBytes("service-account.json"))
 *   3. Collez le resultat dans la variable d'environnement FIREBASE_SERVICE_ACCOUNT_JSON.
 *
 * Option B (alternative) — variables separees :
 *   FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY
 *   (dans un .env classique, remplacez les retours a la ligne de la cle privee par "\n" litteraux ;
 *   ce module les reconvertit automatiquement en vrais retours a la ligne.)
 *
 * Aucune des deux variables n'est requise pour que le serveur demarre, ni pour `tsc --noEmit`
 * ou `prisma validate` : l'initialisation ne se declenche qu'au premier appel a
 * `getFirebaseAuth()`, c'est-a-dire a la premiere requete authentifiee.
 */

let initialized = false;

function initFirebaseApp(): void {
  if (initialized || admin.apps.length > 0) {
    initialized = true;
    return;
  }

  if (env.firebaseServiceAccountJsonBase64) {
    const jsonStr = Buffer.from(env.firebaseServiceAccountJsonBase64, "base64").toString("utf-8");
    const serviceAccount = JSON.parse(jsonStr);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  } else if (env.firebaseProjectId && env.firebaseClientEmail && env.firebasePrivateKey) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: env.firebaseProjectId,
        clientEmail: env.firebaseClientEmail,
        privateKey: env.firebasePrivateKey.replace(/\\n/g, "\n"),
      }),
    });
  } else {
    throw new Error(
      "Configuration Firebase Admin manquante. Renseignez FIREBASE_SERVICE_ACCOUNT_JSON " +
        "(base64) ou le trio FIREBASE_PROJECT_ID / FIREBASE_CLIENT_EMAIL / FIREBASE_PRIVATE_KEY. " +
        "Voir .env.example et README.md."
    );
  }

  initialized = true;
}

export function getFirebaseAuth(): admin.auth.Auth {
  initFirebaseApp();
  return admin.auth();
}

export function getFirebaseMessaging(): admin.messaging.Messaging {
  initFirebaseApp();
  return admin.messaging();
}

export default admin;
