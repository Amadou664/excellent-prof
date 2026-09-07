import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import { createSignalementSchema } from "./signalements.schemas";
import * as signalementsService from "./signalements.service";

export const create = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = createSignalementSchema.parse(req.body);
  const data = await signalementsService.createSignalement(req.user, body);
  res.status(201).json({ data });
});

export const list = asyncHandler(async (_req: Request, res: Response) => {
  const data = await signalementsService.listSignalements();
  res.json({ data });
});

export const markTraite = asyncHandler(async (req: Request, res: Response) => {
  const data = await signalementsService.markTraite(req.params.id);
  res.json({ data });
});
