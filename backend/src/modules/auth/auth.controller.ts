import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import { registerSchema, fcmTokenSchema } from "./auth.schemas";
import * as authService from "./auth.service";

export const register = asyncHandler(async (req: Request, res: Response) => {
  if (!req.firebaseUser) {
    throw ApiError.unauthorized();
  }
  const body = registerSchema.parse(req.body);
  const data = await authService.registerUser({
    firebaseUid: req.firebaseUser.uid,
    email: req.firebaseUser.email,
    body,
  });
  res.status(201).json({ data });
});

export const me = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await authService.getMe(req.user.id);
  res.json({ data });
});

export const setFcmToken = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = fcmTokenSchema.parse(req.body);
  const data = await authService.setFcmToken(req.user.id, body.token);
  res.json({ data });
});
