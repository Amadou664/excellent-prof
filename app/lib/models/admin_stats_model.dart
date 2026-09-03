/// Correspond au schéma de réponse `GET /admin/stats` d'API_CONTRACT.md.
///
/// ```json
/// {
///   "enseignantsValides": 0, "enseignantsEnAttente": 0, "famillesClientes": 0,
///   "elevesInscrits": 0, "demandesEnCours": 0, "avisEnAttenteModeration": 0
/// }
/// ```
///
/// Note (voir API_CONTRACT.md) : le chiffre d'affaires et le taux de
/// fidélisation sont prévus mais leur calcul réel est hors scope tant que le
/// paiement n'est pas défini côté backend -> ils sont donc modélisés ici
/// comme optionnels et valent 0 par défaut (TODO backend/paiement).
class AdminStatsModel {
  final int enseignantsValides;
  final int enseignantsEnAttente;
  final int famillesClientes;
  final int elevesInscrits;
  final int demandesEnCours;
  final int avisEnAttenteModeration;

  /// TODO(backend/paiement) : toujours 0 tant que le module de paiement
  /// n'est pas implémenté côté backend (voir API_CONTRACT.md, note finale).
  final num chiffreAffaires;

  /// TODO(backend/paiement) : idem, calcul réel hors scope pour l'instant.
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
      // TODO(backend/paiement) : lire ces champs une fois exposés par l'API.
      chiffreAffaires: (json['chiffreAffaires'] as num?) ?? 0,
      tauxFidelisation:
          (json['tauxFidelisation'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
