import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import {
  createCoursSchema,
  inscriptionSchema,
  updateCoursSchema,
} from "./coursPourTous.schemas";
import * as coursService from "./coursPourTous.service";

export const list = asyncHandler(async (_req: Request, res: Response) => {
  const data = await coursService.listCours();
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  const body = createCoursSchema.parse(req.body);
  const data = await coursService.createCours(body);
  res.status(201).json({ data });
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const body = updateCoursSchema.parse(req.body);
  const data = await coursService.updateCours(req.params.id, body);
  res.json({ data });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  await coursService.deleteCours(req.params.id);
  res.status(204).send();
});

export const inscription = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = inscriptionSchema.parse(req.body);
  const data = await coursService.inscrire(req.user, req.params.id, body.studentId);
  res.status(201).json({ data });
});
