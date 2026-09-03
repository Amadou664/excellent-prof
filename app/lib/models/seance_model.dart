import 'enums.dart';

/// `Seance` : schéma JSON NON fourni explicitement par API_CONTRACT.md (seuls
/// les endpoints `/seances` sont décrits). Les champs ci-dessous sont déduits
/// des payloads d'entrée/sortie documentés :
/// - `POST /seances` prend `{ demandeId, dateSeance }`.
/// - `PATCH /seances/:id/statut` prend `{ statut: EFFECTUEE|ANNULEE }`.
/// - `GET /seances/mine` doit permettre d'identifier l'élève et le
///   professeur concernés pour l'affichage app-side (`studentId`,
///   `professeurId`, `matiere` déduits de la `Demande` liée).
///
/// Ce modèle lit tous les champs de façon tolérante (`null` accepté) afin de
/// ne pas planter si le backend réel renvoie un sous-ensemble différent. À
/// ajuster dès que le schéma exact de `Seance` sera stabilisé côté backend.
class SeanceModel {
  final String id;
  final String demandeId;
  final DateTime dateSeance;
  final SeanceStatut statut;
  final String? professeurId;
  final String? studentId;
  final String? matiere;
  final bool hasCahierTexte;

  const SeanceModel({
    required this.id,
    required this.demandeId,
    required this.dateSeance,
    required this.statut,
    this.professeurId,
    this.studentId,
    this.matiere,
    this.hasCahierTexte = false,
  });

  factory SeanceModel.fromJson(Map<String, dynamic> json) {
    return SeanceModel(
      id: json['id'] as String,
      demandeId: json['demandeId'] as String? ?? '',
      dateSeance:
          DateTime.tryParse(json['dateSeance'] as String? ?? '') ??
          DateTime.now(),
      statut: SeanceStatut.fromApi(json['statut'] as String? ?? 'PLANIFIEE'),
      professeurId: json['professeurId'] as String?,
      studentId: json['studentId'] as String?,
      matiere: json['matiere'] as String?,
      hasCahierTexte:
          json['hasCahierTexte'] as bool? ?? json['cahierTexte'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'demandeId': demandeId,
      'dateSeance': dateSeance.toIso8601String(),
      'statut': statut.apiValue,
      'professeurId': professeurId,
      'studentId': studentId,
      'matiere': matiere,
    };
  }

  /// Payload pour `POST /seances` : `{ demandeId, dateSeance }`.
  static Map<String, dynamic> createJson({
    required String demandeId,
    required DateTime dateSeance,
  }) {
    return {'demandeId': demandeId, 'dateSeance': dateSeance.toIso8601String()};
  }
}
