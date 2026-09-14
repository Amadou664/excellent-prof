import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import { listActivityQuerySchema, recordVueSchema } from "./activity.schemas";
import * as activityService from "./activity.service";

export const list = asyncHandler(async (req: Request, res: Response) => {
  const query = listActivityQuerySchema.parse(req.query);
  const data = await activityService.list(query);
  res.json({ data });
});

export const recordVue = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = recordVueSchema.parse(req.body);
  await activityService.recordVue(req.user.id, req.user.role, body.ecran);
  res.status(204).end();
});
