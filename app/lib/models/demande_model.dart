import 'enums.dart';

/// Correspond au schéma `Demande` d'API_CONTRACT.md.
///
/// ```json
/// {
///   "id": "uuid", "studentId": "uuid", "matiere": "string", "modePref": "ModePref",
///   "status": "DemandeStatus", "professeurId": "uuid|null", "createdAt": "ISO datetime"
/// }
/// ```
class DemandeModel {
  final String id;
  final String studentId;
  final String matiere;
  final ModePref modePref;
  final DemandeStatus status;
  final String? professeurId;
  final DateTime createdAt;

  /// Non présent dans le schéma officiel mais souvent renvoyé en pratique par
  /// les API REST pour éviter un aller-retour supplémentaire ; lu en tolérant
  /// son absence.
  final String? notes;

  const DemandeModel({
    required this.id,
    required this.studentId,
    required this.matiere,
    required this.modePref,
    required this.status,
    this.professeurId,
    required this.createdAt,
    this.notes,
  });

  factory DemandeModel.fromJson(Map<String, dynamic> json) {
    return DemandeModel(
      id: json['id'] as String,
      studentId: json['studentId'] as String? ?? '',
      matiere: json['matiere'] as String? ?? '',
      modePref: ModePref.fromApi(json['modePref'] as String? ?? 'DOMICILE'),
      status: DemandeStatus.fromApi(json['status'] as String? ?? 'NOUVELLE'),
      professeurId: json['professeurId'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'matiere': matiere,
      'modePref': modePref.apiValue,
      'status': status.apiValue,
      'professeurId': professeurId,
      'createdAt': createdAt.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  /// Payload pour `POST /demandes` : `{ studentId, matiere, modePref, notes? }`.
  static Map<String, dynamic> createJson({
    required String studentId,
    required String matiere,
    required ModePref modePref,
    String? notes,
  }) {
    return {
      'studentId': studentId,
      'matiere': matiere,
      'modePref': modePref.apiValue,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
  }
}
