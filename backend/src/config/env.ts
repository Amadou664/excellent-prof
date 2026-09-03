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
};

export const isProduction = env.nodeEnv === "production";
