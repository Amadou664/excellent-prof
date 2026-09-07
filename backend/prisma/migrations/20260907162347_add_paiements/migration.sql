-- CreateEnum
CREATE TYPE "PaiementStatut" AS ENUM ('EN_ATTENTE', 'REUSSI', 'ECHOUE');

-- CreateTable
CREATE TABLE "Paiement" (
    "id" TEXT NOT NULL,
    "demandeId" TEXT NOT NULL,
    "transactionId" TEXT NOT NULL,
    "montant" INTEGER NOT NULL,
    "devise" TEXT NOT NULL DEFAULT 'XOF',
    "statut" "PaiementStatut" NOT NULL DEFAULT 'EN_ATTENTE',
    "moyenPaiement" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Paiement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Paiement_transactionId_key" ON "Paiement"("transactionId");

-- CreateIndex
CREATE INDEX "Paiement_demandeId_idx" ON "Paiement"("demandeId");

-- CreateIndex
CREATE INDEX "Paiement_statut_idx" ON "Paiement"("statut");

-- AddForeignKey
ALTER TABLE "Paiement" ADD CONSTRAINT "Paiement_demandeId_fkey" FOREIGN KEY ("demandeId") REFERENCES "Demande"("id") ON DELETE CASCADE ON UPDATE CASCADE;
