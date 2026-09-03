import { UserStatus } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import {
  toStudentResponse,
  toTeacherProfileResponse,
  toUserResponse,
} from "../../utils/mappers";
import { RegisterInput } from "./auth.schemas";

export async function registerUser(params: {
  firebaseUid: string;
  email: string;
  body: RegisterInput;
}) {
  const { firebaseUid, email, body } = params;

  const existing = await prisma.user.findUnique({ where: { firebaseUid } });
  if (existing) {
    throw ApiError.conflict(
      "Un compte est deja enregistre pour cet utilisateur Firebase.",
      "USER_ALREADY_REGISTERED"
    );
  }

  const status: UserStatus = body.role === "PROFESSEUR" ? "EN_ATTENTE" : "ACTIF";

  const user = await prisma.$transaction(async (tx) => {
    const created = await tx.user.create({
      data: {
        firebaseUid,
        email,
        telephone: body.telephone,
        nom: body.nom,
        prenom: body.prenom,
        role: body.role,
        status,
        ville: body.ville,
      },
    });

    if (body.role === "PROFESSEUR") {
      await tx.teacherProfile.create({
        data: {
          userId: created.id,
          specialites: body.teacherProfile?.specialites ?? [],
          bio: body.teacherProfile?.bio ?? "",
          diplomesUrls: body.teacherProfile?.diplomesUrls ?? [],
          statutCandidature: "SOUMISE",
        },
      });
    }

    if ((body.role === "ETUDIANT" || body.role === "PARTICULIER") && body.studentSelf) {
      await tx.student.create({
        data: {
          nom: body.nom,
          prenom: body.prenom,
          dateNaissance: body.studentSelf.dateNaissance,
          niveau: body.studentSelf.niveau,
          programme: body.studentSelf.programme,
          userId: created.id,
        },
      });
    }

    return created;
  });

  return toUserResponse(user);
}

export async function getMe(userId: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) {
    throw ApiError.notFound("Utilisateur introuvable");
  }

  const [teacherProfile, students] = await Promise.all([
    prisma.teacherProfile.findUnique({ where: { userId } }),
    prisma.student.findMany({ where: { OR: [{ parentId: userId }, { userId }] } }),
  ]);

  return {
    ...toUserResponse(user),
    teacherProfile: teacherProfile ? toTeacherProfileResponse(teacherProfile, user) : undefined,
    students: students.map(toStudentResponse),
  };
}

export async function setFcmToken(userId: string, token: string) {
  const user = await prisma.user.update({ where: { id: userId }, data: { fcmToken: token } });
  return toUserResponse(user);
}
