-- CreateEnum
CREATE TYPE "SignalementStatut" AS ENUM ('NOUVEAU', 'TRAITE');

-- CreateTable
CREATE TABLE "Signalement" (
    "id" TEXT NOT NULL,
    "auteurId" TEXT NOT NULL,
    "cibleId" TEXT NOT NULL,
    "demandeId" TEXT,
    "motif" TEXT NOT NULL,
    "statut" "SignalementStatut" NOT NULL DEFAULT 'NOUVEAU',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Signalement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Signalement_statut_idx" ON "Signalement"("statut");

-- CreateIndex
CREATE INDEX "Signalement_cibleId_idx" ON "Signalement"("cibleId");

-- AddForeignKey
ALTER TABLE "Signalement" ADD CONSTRAINT "Signalement_auteurId_fkey" FOREIGN KEY ("auteurId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Signalement" ADD CONSTRAINT "Signalement_cibleId_fkey" FOREIGN KEY ("cibleId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
