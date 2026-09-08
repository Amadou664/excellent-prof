import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import { initierPaiementSchema } from "./paiements.schemas";
import * as paiementsService from "./paiements.service";

export const initier = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = initierPaiementSchema.parse(req.body);
  const data = await paiementsService.initierPaiement(req.user, body);
  res.status(201).json({ data });
});

export const statut = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await paiementsService.getStatutPaiement(req.params.demandeId, req.user);
  res.json({ data });
});

export const listAll = asyncHandler(async (_req: Request, res: Response) => {
  const data = await paiementsService.listAllPaiements();
  res.json({ data });
});

/**
 * Appele directement par les serveurs de CinetPay (pas par l'app), en POST ou GET selon leur
 * implementation. Toujours repondre 200 rapidement : CinetPay reessaie sinon, et la verite du
 * statut est de toute facon re-obtenue via l'API de verification, jamais lue ici.
 */
export const webhook = asyncHandler(async (req: Request, res: Response) => {
  const transactionId = (req.body?.cpm_trans_id ?? req.query?.cpm_trans_id) as string | undefined;
  await paiementsService.traiterWebhook(transactionId);
  res.status(200).send("OK");
});
