import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import {
  cahierTexteSchema,
  createSeanceSchema,
  updateSeanceStatutSchema,
} from "./seances.schemas";
import * as seancesService from "./seances.service";

export const getMine = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await seancesService.getMine(req.user);
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = createSeanceSchema.parse(req.body);
  const data = await seancesService.createSeance(req.user, body);
  res.status(201).json({ data });
});

export const updateStatut = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = updateSeanceStatutSchema.parse(req.body);
  const data = await seancesService.updateStatut(req.user, req.params.id, body.statut);
  res.json({ data });
});

export const putCahierTexte = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = cahierTexteSchema.parse(req.body);
  const data = await seancesService.upsertCahierTexte(req.user, req.params.id, body);
  res.json({ data });
});

export const getCahierTexte = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await seancesService.getCahierTexte(req.user, req.params.id);
  res.json({ data });
});
