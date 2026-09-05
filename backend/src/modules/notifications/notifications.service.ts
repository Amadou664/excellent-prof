import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toNotificationResponse } from "../../utils/mappers";

export async function listMine(userId: string) {
  const notifications = await prisma.notification.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
    take: 100,
  });
  return notifications.map(toNotificationResponse);
}

export async function countUnread(userId: string) {
  return prisma.notification.count({ where: { userId, lue: false } });
}

export async function markRead(id: string, userId: string) {
  const notification = await prisma.notification.findUnique({ where: { id } });
  if (!notification || notification.userId !== userId) {
    throw ApiError.notFound("Notification introuvable");
  }
  const updated = await prisma.notification.update({ where: { id }, data: { lue: true } });
  return toNotificationResponse(updated);
}

export async function markAllRead(userId: string) {
  await prisma.notification.updateMany({ where: { userId, lue: false }, data: { lue: true } });
}
