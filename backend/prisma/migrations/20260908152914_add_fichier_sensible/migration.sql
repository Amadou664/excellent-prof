-- AlterTable
ALTER TABLE "Fichier" ADD COLUMN     "sensible" BOOLEAN NOT NULL DEFAULT false;

-- DataFixup: les pieces d'identite deja envoyees avant l'ajout de cette colonne doivent etre
-- marquees sensibles retroactivement (sinon seules les futures pieces d'identite seraient
-- protegees). On extrait l'id du fichier depuis la fin de l'URL stockee dans
-- TeacherProfile.pieceIdentiteUrl (".../api/files/<uuid>").
UPDATE "Fichier" f
SET "sensible" = true
WHERE f.id IN (
  SELECT regexp_replace(tp."pieceIdentiteUrl", '^.*/', '')
  FROM "TeacherProfile" tp
  WHERE tp."pieceIdentiteUrl" IS NOT NULL
);
