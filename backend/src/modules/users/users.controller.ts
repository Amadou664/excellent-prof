import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { listUsersQuerySchema, updateUserStatusSchema } from "./users.schemas";
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
