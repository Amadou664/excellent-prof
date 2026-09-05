import { Prisma, UserStatus } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toUserResponse } from "../../utils/mappers";
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
