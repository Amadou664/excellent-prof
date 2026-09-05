import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import * as notificationsService from "./notifications.service";

export const listMine = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const [items, unreadCount] = await Promise.all([
    notificationsService.listMine(req.user.id),
    notificationsService.countUnread(req.user.id),
  ]);
  res.json({ data: { items, unreadCount } });
});

export const markRead = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await notificationsService.markRead(req.params.id, req.user.id);
  res.json({ data });
});

export const markAllRead = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  await notificationsService.markAllRead(req.user.id);
  res.json({ data: { success: true } });
});
