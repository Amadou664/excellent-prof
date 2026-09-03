/// Correspond au schéma `CoursPourTous` d'API_CONTRACT.md.
///
/// ```json
/// { "id": "uuid", "titre": "string", "description": "string", "matiere": "string",
///   "dateDebut": "ISO datetime", "dateFin": "ISO datetime", "tarif": 5000,
///   "placesDisponibles": 30, "placesRestantes": 12 }
/// ```
class CoursPourTousModel {
  final String id;
  final String titre;
  final String description;
  final String matiere;
  final DateTime dateDebut;
  final DateTime dateFin;
  final num tarif;
  final int placesDisponibles;
  final int placesRestantes;

  const CoursPourTousModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.matiere,
    required this.dateDebut,
    required this.dateFin,
    required this.tarif,
    required this.placesDisponibles,
    required this.placesRestantes,
  });

  bool get complet => placesRestantes <= 0;

  factory CoursPourTousModel.fromJson(Map<String, dynamic> json) {
    return CoursPourTousModel(
      id: json['id'] as String,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      matiere: json['matiere'] as String? ?? '',
      dateDebut:
          DateTime.tryParse(json['dateDebut'] as String? ?? '') ??
          DateTime.now(),
      dateFin:
          DateTime.tryParse(json['dateFin'] as String? ?? '') ??
          DateTime.now(),
      tarif: (json['tarif'] as num?) ?? 0,
      placesDisponibles: (json['placesDisponibles'] as num?)?.toInt() ?? 0,
      placesRestantes: (json['placesRestantes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'matiere': matiere,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'tarif': tarif,
      'placesDisponibles': placesDisponibles,
      'placesRestantes': placesRestantes,
    };
  }

  /// Payload pour `POST /cours-pour-tous` / `PATCH /cours-pour-tous/:id`.
  static Map<String, dynamic> writeJson({
    required String titre,
    required String description,
    required String matiere,
    required DateTime dateDebut,
    required DateTime dateFin,
    required num tarif,
    required int placesDisponibles,
  }) {
    return {
      'titre': titre,
      'description': description,
      'matiere': matiere,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'tarif': tarif,
      'placesDisponibles': placesDisponibles,
    };
  }

  /// Payload pour `POST /cours-pour-tous/:id/inscription` : `{ studentId }`.
  static Map<String, dynamic> inscriptionJson(String studentId) {
    return {'studentId': studentId};
  }
}
