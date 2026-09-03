import { prisma } from "../../config/prisma";

/**
 * GET /admin/stats — voir API_CONTRACT.md. Chaque compteur est calcule via Prisma `count()`.
 * Interpretations retenues (non ambigues dans le contrat mais neanmoins des choix a documenter) :
 *  - enseignantsValides        : TeacherProfile.statutCandidature = VALIDEE
 *  - enseignantsEnAttente      : TeacherProfile.statutCandidature in (SOUMISE, ENTRETIEN)
 *                                 (candidature deposee, decision pas encore rendue)
 *  - famillesClientes          : User.role = PARENT (comptes famille enregistres)
 *  - elevesInscrits            : nombre total de Student (tous rattachements confondus)
 *  - demandesEnCours           : Demande.status hors etats terminaux (TERMINEE, ANNULEE),
 *                                 i.e. NOUVELLE | PROF_PROPOSE | CONFIRMEE | EN_COURS
 *  - avisEnAttenteModeration   : Avis.statut = MASQUE (voir prisma/schema.prisma pour le choix
 *                                 de modelisation de la file de moderation avec seulement 2 etats)
 */
export async function getStats() {
  const [
    enseignantsValides,
    enseignantsEnAttente,
    famillesClientes,
    elevesInscrits,
    demandesEnCours,
    avisEnAttenteModeration,
  ] = await Promise.all([
    prisma.teacherProfile.count({ where: { statutCandidature: "VALIDEE" } }),
    prisma.teacherProfile.count({
      where: { statutCandidature: { in: ["SOUMISE", "ENTRETIEN"] } },
    }),
    prisma.user.count({ where: { role: "PARENT" } }),
    prisma.student.count(),
    prisma.demande.count({
      where: { status: { in: ["NOUVELLE", "PROF_PROPOSE", "CONFIRMEE", "EN_COURS"] } },
    }),
    prisma.avis.count({ where: { statut: "MASQUE" } }),
  ]);

  return {
    enseignantsValides,
    enseignantsEnAttente,
    famillesClientes,
    elevesInscrits,
    demandesEnCours,
    avisEnAttenteModeration,
    // TODO: a calculer une fois le module de paiement defini.
    chiffreAffaires: 0,
    // TODO: a calculer une fois le module de paiement defini.
    tauxFidelisation: 0,
  };
}
