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

app.use(
  cors({
    origin: env.corsOrigin === "*" ? true : env.corsOrigin.split(",").map((s) => s.trim()),
  })
);
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
