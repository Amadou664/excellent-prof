import { Role } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { listActivityQuerySchema } from "./activity.schemas";
import { z } from "zod";

// "/health" : bruit d'infrastructure (verifie par Render/UptimeRobot, pas par un utilisateur).
// "/api/activity" : la requete technique qui alimente le journal (POST, chaque navigation cote
// app) ou le consulte (GET, cote admin) n'est pas elle-meme une activite a raconter — la vraie
// information (l'ecran ouvert) est deja enregistree via recordVue avec method = "VUE".
const ROUTES_IGNOREES = new Set(["/health", "/api/activity"]);

/**
 * Enregistre une ligne du journal d'activite (ADMIN). Best effort : ne doit jamais faire
 * echouer la requete HTTP en cours a cause d'un probleme d'ecriture du journal lui-meme (voir
 * sendPushToUser pour le meme principe).
 */
export async function record(params: {
  userId?: string;
  role?: Role;
  method: string;
  path: string;
  statusCode?: number;
}) {
  if (ROUTES_IGNOREES.has(params.path)) return;
  try {
    await prisma.activityLog.create({
      data: {
        userId: params.userId,
        role: params.role,
        method: params.method,
        path: params.path,
        statusCode: params.statusCode,
      },
    });
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("Echec enregistrement activite:", err);
  }
}

/**
 * Vue d'ecran cote application (navigation Flutter) : ne correspond a aucune requete API a
 * proprement parler, donc envoyee explicitement par le client pour completer le journal au-dela
 * des seules actions qui touchent le serveur.
 */
export async function recordVue(userId: string, role: Role, ecran: string) {
  return record({ userId, role, method: "VUE", path: ecran });
}

export async function list(query: z.infer<typeof listActivityQuerySchema>) {
  const logs = await prisma.activityLog.findMany({
    where: query.userId ? { userId: query.userId } : undefined,
    orderBy: { createdAt: "desc" },
    take: query.limit,
    ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
    include: { user: { select: { nom: true, prenom: true, role: true } } },
  });

  return logs.map((log) => ({
    id: log.id,
    userId: log.userId,
    utilisateur: log.user ? `${log.user.prenom} ${log.user.nom}` : null,
    role: log.role ?? log.user?.role ?? null,
    method: log.method,
    path: log.path,
    statusCode: log.statusCode,
    createdAt: log.createdAt.toISOString(),
  }));
}
