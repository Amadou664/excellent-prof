-- CreateEnum
CREATE TYPE "Role" AS ENUM ('PARENT', 'PROFESSEUR', 'ETUDIANT', 'PARTICULIER', 'ADMIN');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIF', 'EN_ATTENTE', 'SUSPENDU', 'DESACTIVE');

-- CreateEnum
CREATE TYPE "Niveau" AS ENUM ('FONDAMENTAL', 'COLLEGE', 'LYCEE', 'SUPERIEUR');

-- CreateEnum
CREATE TYPE "Programme" AS ENUM ('FRANCAIS', 'MALIEN');

-- CreateEnum
CREATE TYPE "ModePref" AS ENUM ('DOMICILE', 'LIGNE', 'GROUPE');

-- CreateEnum
CREATE TYPE "DemandeStatus" AS ENUM ('NOUVELLE', 'PROF_PROPOSE', 'CONFIRMEE', 'EN_COURS', 'TERMINEE', 'ANNULEE');

-- CreateEnum
CREATE TYPE "StatutCandidature" AS ENUM ('SOUMISE', 'ENTRETIEN', 'VALIDEE', 'REFUSEE');

-- CreateEnum
CREATE TYPE "AnnonceType" AS ENUM ('RECRUTEMENT', 'FORMATION', 'EVENEMENT', 'RESULTAT', 'INFO');

-- CreateEnum
CREATE TYPE "Visibilite" AS ENUM ('PUBLIC', 'CONNECTES');

-- CreateEnum
CREATE TYPE "AvisStatut" AS ENUM ('VISIBLE', 'MASQUE');

-- CreateEnum
CREATE TYPE "SeanceStatut" AS ENUM ('PLANIFIEE', 'EFFECTUEE', 'ANNULEE');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "firebaseUid" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "telephone" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "prenom" TEXT NOT NULL,
    "role" "Role" NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'EN_ATTENTE',
    "ville" TEXT NOT NULL,
    "photoUrl" TEXT,
    "fcmToken" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TeacherProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "specialites" TEXT[],
    "diplomesUrls" TEXT[],
    "bio" TEXT NOT NULL DEFAULT '',
    "zoneGeo" TEXT NOT NULL DEFAULT '',
    "disponibilites" JSONB NOT NULL DEFAULT '{}',
    "statutCandidature" "StatutCandidature" NOT NULL DEFAULT 'SOUMISE',
    "noteMoyenne" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "nombreAvis" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TeacherProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Student" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "prenom" TEXT NOT NULL,
    "dateNaissance" TIMESTAMP(3) NOT NULL,
    "niveau" "Niveau" NOT NULL,
    "programme" "Programme" NOT NULL,
    "parentId" TEXT,
    "userId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Student_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Demande" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "matiere" TEXT NOT NULL,
    "modePref" "ModePref" NOT NULL,
    "status" "DemandeStatus" NOT NULL DEFAULT 'NOUVELLE',
    "notes" TEXT,
    "professeurId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Demande_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Seance" (
    "id" TEXT NOT NULL,
    "demandeId" TEXT NOT NULL,
    "professeurId" TEXT,
    "dateSeance" TIMESTAMP(3) NOT NULL,
    "statut" "SeanceStatut" NOT NULL DEFAULT 'PLANIFIEE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Seance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CahierDeTexte" (
    "id" TEXT NOT NULL,
    "seanceId" TEXT NOT NULL,
    "contenu" TEXT NOT NULL DEFAULT '',
    "exercices" TEXT NOT NULL DEFAULT '',
    "devoirs" TEXT NOT NULL DEFAULT '',
    "observations" TEXT NOT NULL DEFAULT '',
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CahierDeTexte_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Annonce" (
    "id" TEXT NOT NULL,
    "titre" TEXT NOT NULL,
    "contenu" TEXT NOT NULL,
    "type" "AnnonceType" NOT NULL,
    "visibilite" "Visibilite" NOT NULL DEFAULT 'PUBLIC',
    "imageUrl" TEXT,
    "datePublication" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Annonce_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CoursPourTous" (
    "id" TEXT NOT NULL,
    "titre" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "matiere" TEXT NOT NULL,
    "dateDebut" TIMESTAMP(3) NOT NULL,
    "dateFin" TIMESTAMP(3) NOT NULL,
    "tarif" INTEGER NOT NULL,
    "placesDisponibles" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CoursPourTous_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InscriptionCoursPourTous" (
    "id" TEXT NOT NULL,
    "coursId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "InscriptionCoursPourTous_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Avis" (
    "id" TEXT NOT NULL,
    "professeurId" TEXT NOT NULL,
    "auteurId" TEXT NOT NULL,
    "note" INTEGER NOT NULL,
    "commentaire" TEXT NOT NULL,
    "statut" "AvisStatut" NOT NULL DEFAULT 'MASQUE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Avis_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_firebaseUid_key" ON "User"("firebaseUid");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_role_idx" ON "User"("role");

-- CreateIndex
CREATE INDEX "User_status_idx" ON "User"("status");

-- CreateIndex
CREATE UNIQUE INDEX "TeacherProfile_userId_key" ON "TeacherProfile"("userId");

-- CreateIndex
CREATE INDEX "TeacherProfile_statutCandidature_idx" ON "TeacherProfile"("statutCandidature");

-- CreateIndex
CREATE INDEX "Student_parentId_idx" ON "Student"("parentId");

-- CreateIndex
CREATE INDEX "Student_userId_idx" ON "Student"("userId");

-- CreateIndex
CREATE INDEX "Demande_status_idx" ON "Demande"("status");

-- CreateIndex
CREATE INDEX "Demande_professeurId_idx" ON "Demande"("professeurId");

-- CreateIndex
CREATE INDEX "Demande_studentId_idx" ON "Demande"("studentId");

-- CreateIndex
CREATE INDEX "Seance_demandeId_idx" ON "Seance"("demandeId");

-- CreateIndex
CREATE INDEX "Seance_professeurId_idx" ON "Seance"("professeurId");

-- CreateIndex
CREATE UNIQUE INDEX "CahierDeTexte_seanceId_key" ON "CahierDeTexte"("seanceId");

-- CreateIndex
CREATE INDEX "Annonce_visibilite_idx" ON "Annonce"("visibilite");

-- CreateIndex
CREATE INDEX "Annonce_type_idx" ON "Annonce"("type");

-- CreateIndex
CREATE INDEX "CoursPourTous_dateDebut_idx" ON "CoursPourTous"("dateDebut");

-- CreateIndex
CREATE INDEX "InscriptionCoursPourTous_coursId_idx" ON "InscriptionCoursPourTous"("coursId");

-- CreateIndex
CREATE INDEX "InscriptionCoursPourTous_studentId_idx" ON "InscriptionCoursPourTous"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "InscriptionCoursPourTous_coursId_studentId_key" ON "InscriptionCoursPourTous"("coursId", "studentId");

-- CreateIndex
CREATE INDEX "Avis_professeurId_idx" ON "Avis"("professeurId");

-- CreateIndex
CREATE INDEX "Avis_statut_idx" ON "Avis"("statut");

-- AddForeignKey
ALTER TABLE "TeacherProfile" ADD CONSTRAINT "TeacherProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Student" ADD CONSTRAINT "Student_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Student" ADD CONSTRAINT "Student_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Demande" ADD CONSTRAINT "Demande_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Demande" ADD CONSTRAINT "Demande_professeurId_fkey" FOREIGN KEY ("professeurId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Seance" ADD CONSTRAINT "Seance_demandeId_fkey" FOREIGN KEY ("demandeId") REFERENCES "Demande"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Seance" ADD CONSTRAINT "Seance_professeurId_fkey" FOREIGN KEY ("professeurId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CahierDeTexte" ADD CONSTRAINT "CahierDeTexte_seanceId_fkey" FOREIGN KEY ("seanceId") REFERENCES "Seance"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InscriptionCoursPourTous" ADD CONSTRAINT "InscriptionCoursPourTous_coursId_fkey" FOREIGN KEY ("coursId") REFERENCES "CoursPourTous"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InscriptionCoursPourTous" ADD CONSTRAINT "InscriptionCoursPourTous_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Avis" ADD CONSTRAINT "Avis_professeurId_fkey" FOREIGN KEY ("professeurId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Avis" ADD CONSTRAINT "Avis_auteurId_fkey" FOREIGN KEY ("auteurId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
