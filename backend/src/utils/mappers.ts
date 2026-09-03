import {
  Annonce,
  Avis,
  CahierDeTexte,
  CoursPourTous,
  Demande,
  Seance,
  Student,
  TeacherProfile,
  User,
} from "@prisma/client";

/**
 * Fonctions de mise en forme des reponses JSON — chacune ne renvoie QUE les champs documentes
 * dans API_CONTRACT.md pour l'entite correspondante, meme si le modele Prisma sous-jacent
 * contient des colonnes internes supplementaires (fcmToken, updatedAt, etc.).
 */

export function toUserResponse(user: User) {
  return {
    id: user.id,
    firebaseUid: user.firebaseUid,
    email: user.email,
    telephone: user.telephone,
    nom: user.nom,
    prenom: user.prenom,
    role: user.role,
    status: user.status,
    ville: user.ville,
    photoUrl: user.photoUrl,
    createdAt: user.createdAt.toISOString(),
  };
}

export function toStudentResponse(student: Student) {
  return {
    id: student.id,
    nom: student.nom,
    prenom: student.prenom,
    dateNaissance: student.dateNaissance.toISOString(),
    niveau: student.niveau,
    programme: student.programme,
    parentId: student.parentId,
    userId: student.userId,
  };
}

export function toTeacherProfileResponse(
  profile: TeacherProfile,
  user: Pick<User, "nom" | "prenom" | "ville" | "photoUrl">
) {
  return {
    id: profile.id,
    userId: profile.userId,
    specialites: profile.specialites,
    diplomesUrls: profile.diplomesUrls,
    bio: profile.bio,
    zoneGeo: profile.zoneGeo,
    disponibilites: profile.disponibilites,
    statutCandidature: profile.statutCandidature,
    noteMoyenne: profile.noteMoyenne,
    nombreAvis: profile.nombreAvis,
    user: {
      nom: user.nom,
      prenom: user.prenom,
      ville: user.ville,
      photoUrl: user.photoUrl,
    },
  };
}

export function toDemandeResponse(demande: Demande) {
  return {
    id: demande.id,
    studentId: demande.studentId,
    matiere: demande.matiere,
    modePref: demande.modePref,
    status: demande.status,
    professeurId: demande.professeurId,
    createdAt: demande.createdAt.toISOString(),
  };
}

export function toSeanceResponse(seance: Seance) {
  return {
    id: seance.id,
    demandeId: seance.demandeId,
    professeurId: seance.professeurId,
    dateSeance: seance.dateSeance.toISOString(),
    statut: seance.statut,
  };
}

export function toCahierResponse(cahier: CahierDeTexte) {
  return {
    id: cahier.id,
    seanceId: cahier.seanceId,
    contenu: cahier.contenu,
    exercices: cahier.exercices,
    devoirs: cahier.devoirs,
    observations: cahier.observations,
    updatedAt: cahier.updatedAt.toISOString(),
  };
}

export function toAnnonceResponse(annonce: Annonce) {
  return {
    id: annonce.id,
    titre: annonce.titre,
    contenu: annonce.contenu,
    type: annonce.type,
    visibilite: annonce.visibilite,
    imageUrl: annonce.imageUrl,
    datePublication: annonce.datePublication.toISOString(),
  };
}

export function toCoursResponse(cours: CoursPourTous, placesRestantes: number) {
  return {
    id: cours.id,
    titre: cours.titre,
    description: cours.description,
    matiere: cours.matiere,
    dateDebut: cours.dateDebut.toISOString(),
    dateFin: cours.dateFin.toISOString(),
    tarif: cours.tarif,
    placesDisponibles: cours.placesDisponibles,
    placesRestantes,
  };
}

export function toAvisResponse(avis: Avis) {
  return {
    id: avis.id,
    professeurId: avis.professeurId,
    auteurId: avis.auteurId,
    note: avis.note,
    commentaire: avis.commentaire,
    statut: avis.statut,
    createdAt: avis.createdAt.toISOString(),
  };
}
