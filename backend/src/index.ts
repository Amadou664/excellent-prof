import express from "express";
import cors from "cors";
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

const app = express();

// L'authentification se fait via un token Firebase en en-tete `Authorization: Bearer`, jamais
// via cookie : un CORS ouvert n'expose donc pas de risque CSRF ici. On reflete systematiquement
// l'origine de la requete plutot que de dependre d'une comparaison stricte sur CORS_ORIGIN
// (fragile : un espace ou une casse differente sur la valeur stockee cote hebergeur suffit a
// silencieusement bloquer TOUTES les requetes navigateur, sans que le serveur ne renvoie
// d'erreur explicite).
app.use(cors({ origin: true }));
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ data: { status: "ok" } });
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

app.use((req, res) => {
  res.status(404).json({ error: { code: "NOT_FOUND", message: `Route inconnue: ${req.method} ${req.path}` } });
});

// Toujours en dernier.
app.use(errorHandler);

app.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`L'Excellent Prof API demarree sur le port ${env.port} (env: ${env.nodeEnv})`);
});

export default app;
