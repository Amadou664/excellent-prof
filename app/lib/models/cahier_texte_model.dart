/// Correspond au schéma `CahierDeTexte` d'API_CONTRACT.md.
///
/// ```json
/// { "id": "uuid", "seanceId": "uuid", "contenu": "string", "exercices": "string",
///   "devoirs": "string", "observations": "string", "updatedAt": "ISO datetime" }
/// ```
class CahierTexteModel {
  final String id;
  final String seanceId;
  final String contenu;
  final String exercices;
  final String devoirs;
  final String observations;
  final DateTime updatedAt;

  const CahierTexteModel({
    required this.id,
    required this.seanceId,
    required this.contenu,
    required this.exercices,
    required this.devoirs,
    required this.observations,
    required this.updatedAt,
  });

  factory CahierTexteModel.fromJson(Map<String, dynamic> json) {
    return CahierTexteModel(
      id: json['id'] as String? ?? '',
      seanceId: json['seanceId'] as String? ?? '',
      contenu: json['contenu'] as String? ?? '',
      exercices: json['exercices'] as String? ?? '',
      devoirs: json['devoirs'] as String? ?? '',
      observations: json['observations'] as String? ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seanceId': seanceId,
      'contenu': contenu,
      'exercices': exercices,
      'devoirs': devoirs,
      'observations': observations,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Payload pour `PUT /seances/:id/cahier-texte` :
  /// `{ contenu, exercices, devoirs, observations }`.
  static Map<String, dynamic> upsertJson({
    required String contenu,
    required String exercices,
    required String devoirs,
    required String observations,
  }) {
    return {
      'contenu': contenu,
      'exercices': exercices,
      'devoirs': devoirs,
      'observations': observations,
    };
  }

  bool get estVide =>
      contenu.isEmpty && exercices.isEmpty && devoirs.isEmpty && observations.isEmpty;
}
