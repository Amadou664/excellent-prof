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
 *  - chiffreAffaires           : somme de Demande.montant pour les demandes marquees `paye`
 *                                 (voir suivi de paiement manuel sur le modele Demande — pas de
 *                                 passerelle de paiement integree, un ADMIN bascule ce champ)
 *  - tauxFidelisation          : % de familles (proprietaires de Student, via parentId ou
 *                                 userId) ayant cree au moins 2 Demande, parmi celles en ayant
 *                                 cree au moins 1
 */
export async function getStats() {
  const [
    enseignantsValides,
    enseignantsEnAttente,
    famillesClientes,
    elevesInscrits,
    demandesEnCours,
    avisEnAttenteModeration,
    revenueAggregate,
    demandesAvecProprietaire,
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
    prisma.demande.aggregate({ where: { paye: true }, _sum: { montant: true } }),
    prisma.demande.findMany({
      select: { student: { select: { parentId: true, userId: true } } },
    }),
  ]);

  const demandesParFamille = new Map<string, number>();
  for (const { student } of demandesAvecProprietaire) {
    const ownerId = student.parentId ?? student.userId;
    if (!ownerId) continue;
    demandesParFamille.set(ownerId, (demandesParFamille.get(ownerId) ?? 0) + 1);
  }
  const totalFamilles = demandesParFamille.size;
  const famillesFideles = [...demandesParFamille.values()].filter((count) => count >= 2).length;
  const tauxFidelisation =
    totalFamilles > 0 ? Math.round((famillesFideles / totalFamilles) * 100) : 0;

  return {
    enseignantsValides,
    enseignantsEnAttente,
    famillesClientes,
    elevesInscrits,
    demandesEnCours,
    avisEnAttenteModeration,
    chiffreAffaires: revenueAggregate._sum.montant ?? 0,
    tauxFidelisation,
  };
}
