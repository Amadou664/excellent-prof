import { Prisma, UserStatus } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { getFirebaseAuth } from "../../config/firebaseAdmin";
import { ApiError } from "../../utils/apiError";
import {
  toStudentResponse,
  toTeacherProfileResponse,
  toUserResponse,
} from "../../utils/mappers";
import { z } from "zod";
import { listUsersQuerySchema, updateMeSchema } from "./users.schemas";

type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;

export async function listUsers(query: ListUsersQuery) {
  const where: Prisma.UserWhereInput = {};
  if (query.role) where.role = query.role;
  if (query.status) where.status = query.status;
  if (query.q) {
    where.OR = [
      { nom: { contains: query.q, mode: "insensitive" } },
      { prenom: { contains: query.q, mode: "insensitive" } },
      { email: { contains: query.q, mode: "insensitive" } },
      { telephone: { contains: query.q, mode: "insensitive" } },
    ];
  }

  const [total, users] = await Promise.all([
    prisma.user.count({ where }),
    prisma.user.findMany({
      where,
      orderBy: { createdAt: "desc" },
      skip: (query.page - 1) * query.pageSize,
      take: query.pageSize,
    }),
  ]);

  return {
    items: users.map(toUserResponse),
    page: query.page,
    pageSize: query.pageSize,
    total,
  };
}

export async function updateUserStatus(id: string, status: UserStatus) {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) {
    throw ApiError.notFound("Utilisateur introuvable");
  }
  const updated = await prisma.user.update({ where: { id }, data: { status } });
  return toUserResponse(updated);
}

export async function updateMe(userId: string, body: z.infer<typeof updateMeSchema>) {
  const updated = await prisma.user.update({ where: { id: userId }, data: body });
  return toUserResponse(updated);
}

/**
 * Suppression definitive de son propre compte (promise dans la politique de confidentialite).
 * La suppression Postgres cascade sur toutes les donnees liees (voir onDelete: Cascade dans
 * prisma/schema.prisma : students, demandes, messages, avis, notifications, signalements...).
 * Le compte Firebase Auth associe est aussi supprime en best-effort : un echec ici ne bloque pas
 * la suppression (deja effective cote donnees applicatives, et verifyFirebaseToken refusera de
 * toute facon tout token pour ce compte des lors qu'aucun User ne lui correspond plus).
 */
export async function deleteMe(userId: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) {
    throw ApiError.notFound("Utilisateur introuvable");
  }
  await prisma.user.delete({ where: { id: userId } });
  try {
    await getFirebaseAuth().deleteUser(user.firebaseUid);
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("Echec suppression compte Firebase (donnees applicatives deja supprimees):", err);
  }
}

/**
 * Fiche detaillee d'un utilisateur (ADMIN) : profil de base + son
 * teacherProfile (le cas echeant), ses eleves (rattaches en tant que
 * parent/etudiant/particulier), et deux compteurs de demandes selon le role
 * (famille -> demandes creees pour ses eleves ; professeur -> demandes qui
 * lui ont ete assignees), pour eviter un aller-retour supplementaire cote
 * app quand l'admin consulte ce profil.
 */
export async function getUserDetail(id: string) {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) {
    throw ApiError.notFound("Utilisateur introuvable");
  }

  const [teacherProfile, students, demandesCommeFamille, demandesCommeProf, avisRecus] =
    await Promise.all([
      prisma.teacherProfile.findUnique({ where: { userId: id } }),
      prisma.student.findMany({ where: { OR: [{ parentId: id }, { userId: id }] } }),
      prisma.demande.count({ where: { student: { OR: [{ parentId: id }, { userId: id }] } } }),
      prisma.demande.count({ where: { professeurId: id } }),
      prisma.avis.count({ where: { professeurId: id, statut: "VISIBLE" } }),
    ]);

  return {
    ...toUserResponse(user),
    teacherProfile: teacherProfile ? toTeacherProfileResponse(teacherProfile, user) : undefined,
    students: students.map(toStudentResponse),
    demandesCommeFamille,
    demandesCommeProf,
    avisRecus,
  };
}
