import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { env } from "./config/env";
import { errorHandler } from "./middleware/errorHandler";

import authRoutes from "./modules/auth/auth.routes";
import usersRoutes from "./modules/users/users.routes";
import teachersRoutes from "./modules/teachers/teachers.routes";
import studentsRoutes from "./modules/students/students.routes";
import demandesRoutes from "./modules/demandes/demandes.routes";
import seancesRoutes from "./modules/seances/seances.routes";
import annoncesRoutes from "./modules/annonces/annonces.routes";
import coursPourTousRoutes from "./modules/coursPourTous/coursPourTous.routes";
import avisRoutes from "./modules/avis/avis.routes";
import adminStatsRoutes from "./modules/admin/stats.routes";
import filesRoutes from "./modules/files/files.routes";
import notificationsRoutes from "./modules/notifications/notifications.routes";
import signalementsRoutes from "./modules/signalements/signalements.routes";
import { prisma } from "./config/prisma";

const app = express();

// Necessaire sur Render (derriere un proxy Cloudflare) pour que `req.ip` / express-rate-limit
// lisent la vraie IP cliente via `X-Forwarded-For` plutot que l'IP du proxy (qui serait alors
// partagee par tous les visiteurs et ferait declencher les limites ci-dessous a tort).
app.set("trust proxy", 1);

// Durcit une serie d'en-tetes HTTP par defaut (anti-clickjacking, desactive le sniffing MIME,
// cache le "X-Powered-By: Express" qui renseignait un attaquant sur la stack utilisee, HSTS,
// etc.). `crossOriginResourcePolicy` doit rester "cross-origin" : le front (excellent-prof.web.app)
// et l'API (excellent-prof-backend.onrender.com) sont sur des domaines differents, et les images
// (photos de profil, diplomes) servies par /api/files doivent pouvoir etre chargees depuis le
// front — le defaut "same-origin" de Helmet les bloquerait silencieusement.
app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));

// L'authentification se fait via un token Firebase en en-tete `Authorization: Bearer`, jamais
// via cookie : un CORS ouvert n'expose donc pas de risque CSRF ici. On reflete systematiquement
// l'origine de la requete plutot que de dependre d'une comparaison stricte sur CORS_ORIGIN
// (fragile : un espace ou une casse differente sur la valeur stockee cote hebergeur suffit a
// silencieusement bloquer TOUTES les requetes navigateur, sans que le serveur ne renvoie
// d'erreur explicite).
app.use(cors({ origin: true }));
app.use(express.json());

// Limite globale anti-abus (ex: scraping massif, bourrinage generique). Volontairement large
// pour ne jamais gener un usage normal.
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 300,
    standardHeaders: true,
    legacyHeaders: false,
  })
);

// Limite stricte sur la creation de compte (spam de faux comptes). L'upload de fichiers a sa
// propre limite, appliquee uniquement au POST dans files.routes.ts (le GET de lecture, mis en
// cache navigateur/CDN sur 1 an, ne doit pas etre restreint de la meme facon).
app.use(
  "/api/auth/register",
  rateLimit({
    windowMs: 60 * 60 * 1000,
    limit: 20,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: { code: "RATE_LIMITED", message: "Trop de tentatives. Reessayez plus tard." } },
  })
);

// Verifie aussi que la base de donnees repond, pas seulement que le process Express tourne :
// un outil de supervision externe (UptimeRobot, etc.) branche sur cette route detecte ainsi une
// vraie panne (DB injoignable) et pas seulement un serveur qui repond sans pouvoir rien faire.
app.get("/health", async (_req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({ data: { status: "ok", database: "ok" } });
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("Health check: base de donnees injoignable:", err);
    res.status(503).json({ data: { status: "degraded", database: "unreachable" } });
  }
});

app.use("/api/auth", authRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/teachers", teachersRoutes);
app.use("/api/students", studentsRoutes);
app.use("/api/demandes", demandesRoutes);
app.use("/api/seances", seancesRoutes);
app.use("/api/annonces", annoncesRoutes);
app.use("/api/cours-pour-tous", coursPourTousRoutes);
app.use("/api/avis", avisRoutes);
app.use("/api/admin", adminStatsRoutes);
app.use("/api/files", filesRoutes);
app.use("/api/notifications", notificationsRoutes);
app.use("/api/signalements", signalementsRoutes);

app.use((req, res) => {
  res.status(404).json({ error: { code: "NOT_FOUND", message: `Route inconnue: ${req.method} ${req.path}` } });
});

// Toujours en dernier.
app.use(errorHandler);

const server = app.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`L'Excellent Prof API demarree sur le port ${env.port} (env: ${env.nodeEnv})`);
});

// Sans ces handlers, une erreur asynchrone non rattrapee ailleurs (ex: une promesse oubliee
// hors du chemin `asyncHandler`) fait planter tout le process Node instantanement, coupant TOUTES
// les requetes en cours le temps que Render redemarre le service. On logge et on laisse le
// serveur continuer a tourner plutot que de crasher pour une seule requete fautive.
process.on("unhandledRejection", (reason) => {
  // eslint-disable-next-line no-console
  console.error("Unhandled promise rejection:", reason);
});
process.on("uncaughtException", (err) => {
  // eslint-disable-next-line no-console
  console.error("Uncaught exception:", err);
});

// Render envoie SIGTERM avant de redemarrer le service (nouveau deploiement, mise a l'echelle...).
// Sans ce handler, les requetes en cours au moment du signal sont coupees net et la connexion
// Prisma n'est jamais fermee proprement. Ici : on arrete d'accepter de nouvelles requetes, on
// laisse les requetes en cours se terminer, puis on ferme la connexion DB avant de quitter.
function shutdown() {
  // eslint-disable-next-line no-console
  console.log("Signal d'arret recu, fermeture propre du serveur...");
  server.close(() => {
    prisma
      .$disconnect()
      .catch(() => undefined)
      .finally(() => process.exit(0));
  });
  // Filet de securite : si des requetes trainent, on force l'arret apres 10s plutot que de
  // bloquer indefiniment le redemarrage.
  setTimeout(() => process.exit(1), 10_000).unref();
}
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);

export default app;
