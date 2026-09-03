import { User } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toStudentResponse } from "../../utils/mappers";
import { z } from "zod";
import { createStudentSchema, updateStudentSchema } from "./students.schemas";

export async function getMine(user: User) {
  const students = await prisma.student.findMany({
    where: { OR: [{ parentId: user.id }, { userId: user.id }] },
    orderBy: { createdAt: "asc" },
  });
  return students.map(toStudentResponse);
}

export async function createStudent(
  parent: User,
  body: z.infer<typeof createStudentSchema>
) {
  const student = await prisma.student.create({
    data: {
      nom: body.nom,
      prenom: body.prenom,
      dateNaissance: body.dateNaissance,
      niveau: body.niveau,
      programme: body.programme,
      parentId: parent.id,
    },
  });
  return toStudentResponse(student);
}

async function assertOwnerOrAdmin(user: User, studentId: string) {
  const student = await prisma.student.findUnique({ where: { id: studentId } });
  if (!student) {
    throw ApiError.notFound("Eleve introuvable");
  }
  const isOwner = student.parentId === user.id || student.userId === user.id;
  if (!isOwner && user.role !== "ADMIN") {
    throw ApiError.forbidden("Vous n'etes pas autorise a modifier cet eleve");
  }
  return student;
}

export async function updateStudent(
  user: User,
  studentId: string,
  body: z.infer<typeof updateStudentSchema>
) {
  await assertOwnerOrAdmin(user, studentId);
  const updated = await prisma.student.update({
    where: { id: studentId },
    data: {
      ...(body.nom !== undefined ? { nom: body.nom } : {}),
      ...(body.prenom !== undefined ? { prenom: body.prenom } : {}),
      ...(body.dateNaissance !== undefined ? { dateNaissance: body.dateNaissance } : {}),
      ...(body.niveau !== undefined ? { niveau: body.niveau } : {}),
      ...(body.programme !== undefined ? { programme: body.programme } : {}),
    },
  });
  return toStudentResponse(updated);
}

export async function deleteStudent(user: User, studentId: string) {
  await assertOwnerOrAdmin(user, studentId);
  await prisma.student.delete({ where: { id: studentId } });
}
