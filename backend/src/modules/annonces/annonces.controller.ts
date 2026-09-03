import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { createAnnonceSchema, updateAnnonceSchema } from "./annonces.schemas";
import * as annoncesService from "./annonces.service";

export const list = asyncHandler(async (req: Request, res: Response) => {
  const data = await annoncesService.listAnnonces(Boolean(req.user));
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  const body = createAnnonceSchema.parse(req.body);
  const data = await annoncesService.createAnnonce(body);
  res.status(201).json({ data });
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const body = updateAnnonceSchema.parse(req.body);
  const data = await annoncesService.updateAnnonce(req.params.id, body);
  res.json({ data });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  await annoncesService.deleteAnnonce(req.params.id);
  res.status(204).send();
});
