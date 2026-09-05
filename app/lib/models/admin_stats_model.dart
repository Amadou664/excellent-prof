/// Correspond au schéma de réponse `GET /admin/stats` d'API_CONTRACT.md.
///
/// ```json
/// {
///   "enseignantsValides": 0, "enseignantsEnAttente": 0, "famillesClientes": 0,
///   "elevesInscrits": 0, "demandesEnCours": 0, "avisEnAttenteModeration": 0
/// }
/// ```
///
class AdminStatsModel {
  final int enseignantsValides;
  final int enseignantsEnAttente;
  final int famillesClientes;
  final int elevesInscrits;
  final int demandesEnCours;
  final int avisEnAttenteModeration;

  /// Somme des `Demande.montant` marquées `paye` (voir suivi de paiement
  /// manuel, `PATCH /demandes/:id/paiement`).
  final num chiffreAffaires;

  /// Déjà exprimé en pourcentage (0-100) par le backend — ne PAS multiplier
  /// par 100 à l'affichage.
  final double tauxFidelisation;

  const AdminStatsModel({
    required this.enseignantsValides,
    required this.enseignantsEnAttente,
    required this.famillesClientes,
    required this.elevesInscrits,
    required this.demandesEnCours,
    required this.avisEnAttenteModeration,
    this.chiffreAffaires = 0,
    this.tauxFidelisation = 0,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      enseignantsValides: (json['enseignantsValides'] as num?)?.toInt() ?? 0,
      enseignantsEnAttente:
          (json['enseignantsEnAttente'] as num?)?.toInt() ?? 0,
      famillesClientes: (json['famillesClientes'] as num?)?.toInt() ?? 0,
      elevesInscrits: (json['elevesInscrits'] as num?)?.toInt() ?? 0,
      demandesEnCours: (json['demandesEnCours'] as num?)?.toInt() ?? 0,
      avisEnAttenteModeration:
          (json['avisEnAttenteModeration'] as num?)?.toInt() ?? 0,
      chiffreAffaires: (json['chiffreAffaires'] as num?) ?? 0,
      tauxFidelisation:
          (json['tauxFidelisation'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
