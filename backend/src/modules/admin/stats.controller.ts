import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import * as statsService from "./stats.service";

export const getStats = asyncHandler(async (_req: Request, res: Response) => {
  const data = await statsService.getStats();
  res.json({ data });
});
