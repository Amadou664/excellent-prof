import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import {
  listTeachersQuerySchema,
  updateCandidatureSchema,
  updateMyTeacherProfileSchema,
} from "./teachers.schemas";
import * as teachersService from "./teachers.service";

export const getMe = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await teachersService.getMyProfile(req.user.id);
  res.json({ data });
});

export const updateMe = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = updateMyTeacherProfileSchema.parse(req.body);
  const data = await teachersService.updateMyProfile(req.user.id, body);
  res.json({ data });
});

export const list = asyncHandler(async (req: Request, res: Response) => {
  const query = listTeachersQuerySchema.parse(req.query);
  const data = await teachersService.listTeachers(query);
  res.json({ data });
});

export const updateCandidature = asyncHandler(async (req: Request, res: Response) => {
  const body = updateCandidatureSchema.parse(req.body);
  const data = await teachersService.updateCandidature(req.params.id, body.statutCandidature);
  res.json({ data });
});
