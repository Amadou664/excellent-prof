import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import { createAvisSchema, listAvisQuerySchema, updateAvisStatutSchema } from "./avis.schemas";
import * as avisService from "./avis.service";

export const create = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = createAvisSchema.parse(req.body);
  const data = await avisService.createAvis(req.user, body);
  res.status(201).json({ data });
});

export const list = asyncHandler(async (req: Request, res: Response) => {
  const query = listAvisQuerySchema.parse(req.query);
  if (query.professeurId) {
    const data = await avisService.listAvisForProfesseur(query.professeurId);
    return res.json({ data });
  }
  // Sans professeurId : liste de moderation, reservee a l'ADMIN.
  if (!req.user || req.user.role !== "ADMIN") {
    throw ApiError.forbidden("professeurId requis, ou reserve a l'ADMIN pour la moderation");
  }
  const data = await avisService.listAvisForModeration();
  res.json({ data });
});

export const updateStatut = asyncHandler(async (req: Request, res: Response) => {
  const body = updateAvisStatutSchema.parse(req.body);
  const data = await avisService.updateStatut(req.params.id, body.statut);
  res.json({ data });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  await avisService.deleteAvis(req.params.id);
  res.status(204).send();
});
