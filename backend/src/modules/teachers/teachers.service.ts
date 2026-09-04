import { Prisma } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { ApiError } from "../../utils/apiError";
import { toTeacherProfileResponse } from "../../utils/mappers";
import { sendPushToUser } from "../../utils/push";
import { z } from "zod";
import { listTeachersQuerySchema, updateMyTeacherProfileSchema } from "./teachers.schemas";

async function findProfileWithUserOrThrow(where: Prisma.TeacherProfileWhereUniqueInput) {
  const profile = await prisma.teacherProfile.findUnique({ where, include: { user: true } });
  if (!profile) {
    throw ApiError.notFound("Profil enseignant introuvable");
  }
  return profile;
}

export async function getMyProfile(userId: string) {
  const profile = await findProfileWithUserOrThrow({ userId });
  return toTeacherProfileResponse(profile, profile.user);
}

export async function updateMyProfile(
  userId: string,
  body: z.infer<typeof updateMyTeacherProfileSchema>
) {
  await findProfileWithUserOrThrow({ userId });
  const updated = await prisma.teacherProfile.update({
    where: { userId },
    data: {
      ...(body.specialites !== undefined ? { specialites: body.specialites } : {}),
      ...(body.bio !== undefined ? { bio: body.bio } : {}),
      ...(body.disponibilites !== undefined
        ? { disponibilites: body.disponibilites as Prisma.InputJsonValue }
        : {}),
      ...(body.zoneGeo !== undefined ? { zoneGeo: body.zoneGeo } : {}),
    },
    include: { user: true },
  });
  return toTeacherProfileResponse(updated, updated.user);
}

export async function listTeachers(query: z.infer<typeof listTeachersQuerySchema>) {
  const where: Prisma.TeacherProfileWhereInput = {};
  if (query.statutCandidature) where.statutCandidature = query.statutCandidature;
  if (query.specialite) where.specialites = { has: query.specialite };
  if (query.ville) where.user = { ville: { contains: query.ville, mode: "insensitive" } };

  const profiles = await prisma.teacherProfile.findMany({
    where,
    include: { user: true },
    orderBy: { createdAt: "desc" },
  });

  return profiles.map((profile) => toTeacherProfileResponse(profile, profile.user));
}

export async function updateCandidature(
  teacherProfileId: string,
  statutCandidature: "VALIDEE" | "REFUSEE" | "ENTRETIEN"
) {
  const profile = await findProfileWithUserOrThrow({ id: teacherProfileId });

  const updated = await prisma.$transaction(async (tx) => {
    const updatedProfile = await tx.teacherProfile.update({
      where: { id: teacherProfileId },
      data: { statutCandidature },
      include: { user: true },
    });

    if (statutCandidature === "VALIDEE") {
      const updatedUser = await tx.user.update({
        where: { id: profile.userId },
        data: { status: "ACTIF" },
      });
      updatedProfile.user = updatedUser;
    }

    return updatedProfile;
  });

  if (statutCandidature === "VALIDEE") {
    await sendPushToUser(
      profile.userId,
      "Candidature validee",
      "Felicitations, votre candidature a ete validee ! Vous pouvez maintenant utiliser l'application."
    );
  } else if (statutCandidature === "REFUSEE") {
    await sendPushToUser(
      profile.userId,
      "Candidature non retenue",
      "Votre candidature n'a malheureusement pas ete retenue cette fois-ci."
    );
  }

  return toTeacherProfileResponse(updated, updated.user);
}
