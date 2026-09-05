import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import { listUsersQuerySchema, updateMeSchema, updateUserStatusSchema } from "./users.schemas";
import * as usersService from "./users.service";

export const list = asyncHandler(async (req: Request, res: Response) => {
  const query = listUsersQuerySchema.parse(req.query);
  const data = await usersService.listUsers(query);
  res.json({ data });
});

export const updateStatus = asyncHandler(async (req: Request, res: Response) => {
  const body = updateUserStatusSchema.parse(req.body);
  const data = await usersService.updateUserStatus(req.params.id, body.status);
  res.json({ data });
});

export const updateMe = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = updateMeSchema.parse(req.body);
  const data = await usersService.updateMe(req.user.id, body);
  res.json({ data });
});

export const getDetail = asyncHandler(async (req: Request, res: Response) => {
  const data = await usersService.getUserDetail(req.params.id);
  res.json({ data });
});
