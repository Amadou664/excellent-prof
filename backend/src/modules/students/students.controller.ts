import { Request, Response } from "express";
import { asyncHandler } from "../../utils/asyncHandler";
import { ApiError } from "../../utils/apiError";
import { createStudentSchema, updateStudentSchema } from "./students.schemas";
import * as studentsService from "./students.service";

export const getMine = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const data = await studentsService.getMine(req.user);
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = createStudentSchema.parse(req.body);
  const data = await studentsService.createStudent(req.user, body);
  res.status(201).json({ data });
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  const body = updateStudentSchema.parse(req.body);
  const data = await studentsService.updateStudent(req.user, req.params.id, body);
  res.json({ data });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  if (!req.user) throw ApiError.unauthorized();
  await studentsService.deleteStudent(req.user, req.params.id);
  res.status(204).send();
});
