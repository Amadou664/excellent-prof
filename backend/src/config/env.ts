import dotenv from "dotenv";

dotenv.config();

function readString(name: string, fallback?: string): string {
  const value = process.env[name];
  if (value === undefined || value === "") {
    if (fallback !== undefined) return fallback;
    return "";
  }
  return value;
}

export const env = {
  nodeEnv: readString("NODE_ENV", "development"),
  port: parseInt(readString("PORT", "4000"), 10),

  databaseUrl: readString("DATABASE_URL"),

  corsOrigin: readString("CORS_ORIGIN", "*"),

  // Firebase Admin — voir src/config/firebaseAdmin.ts pour le detail des deux modes de config.
  firebaseServiceAccountJsonBase64: readString("FIREBASE_SERVICE_ACCOUNT_JSON"),
  firebaseProjectId: readString("FIREBASE_PROJECT_ID"),
  firebaseClientEmail: readString("FIREBASE_CLIENT_EMAIL"),
  firebasePrivateKey: readString("FIREBASE_PRIVATE_KEY"),

  // Paiement en ligne (CinetPay) — voir src/modules/paiements. Tant que ces deux valeurs ne sont
  // pas renseignees (compte marchand pas encore cree), `POST /paiements/initier` repond une
  // erreur claire plutot que de planter : le reste de l'app continue de fonctionner normalement.
  cinetpayApiKey: readString("CINETPAY_API_KEY"),
  cinetpaySiteId: readString("CINETPAY_SITE_ID"),

  // URLs publiques utilisees pour construire notify_url/return_url envoyes a CinetPay.
  backendPublicUrl: readString("BACKEND_PUBLIC_URL", "https://excellent-prof-backend.onrender.com"),
  webPublicUrl: readString("WEB_PUBLIC_URL", "https://excellent-prof.web.app"),

  // Suivi d'erreurs (Sentry) — voir src/instrument.ts. Vide tant que le compte n'est pas cree.
  sentryDsn: readString("SENTRY_DSN"),
};

export const isProduction = env.nodeEnv === "production";
