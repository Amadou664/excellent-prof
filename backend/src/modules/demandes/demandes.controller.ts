import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import {
  assignerSchema,
  confirmerSchema,
  createDemandeSchema,
  listDemandesQuerySchema,
} from "./demandes.schemas";
import * as demandesService from "./demandes.service";

export const create = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = createDemandeSchema.parse(req.body);
  const data = await demandesService.createDemande(req.user, body);
  res.status(201).json({ data });
});

export const getMine = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await demandesService.getMine(req.user);
  res.json({ data });
});

export const list = asyncHandler(async (req: Request, res: Response) => {
  const query = listDemandesQuerySchema.parse(req.query);
  const data = await demandesService.listDemandes(query);
  res.json({ data });
});

export const assigner = asyncHandler(async (req: Request, res: Response) => {
  const body = assignerSchema.parse(req.body);
  const data = await demandesService.assigner(req.params.id, body.professeurId);
  res.json({ data });
});

export const confirmer = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = confirmerSchema.parse(req.body ?? {});
  const data = await demandesService.confirmer(req.params.id, req.user, body?.dateSeance);
  res.json({ data });
});

export const annuler = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await demandesService.annuler(req.params.id, req.user);
  res.json({ data });
});
