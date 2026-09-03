import 'enums.dart';

/// `Avis` : schéma JSON complet NON fourni par API_CONTRACT.md (seul le
/// payload de création `{ professeurId, note, commentaire }` et le filtre de
/// lecture `GET /avis?professeurId=` sont documentés). Les champs
/// additionnels ci-dessous (`id`, `statut`, `createdAt`, `auteurNom`) sont
/// déduits du besoin fonctionnel (modération admin via `AvisStatut`,
/// affichage de la liste des avis) et lus de façon tolérante.
class AvisModel {
  final String id;
  final String professeurId;
  final int note;
  final String commentaire;
  final AvisStatut statut;
  final DateTime createdAt;

  /// Nom d'affichage de l'auteur si renvoyé par le backend (ex: "Awa D.").
  final String? auteurNom;

  const AvisModel({
    required this.id,
    required this.professeurId,
    required this.note,
    required this.commentaire,
    required this.statut,
    required this.createdAt,
    this.auteurNom,
  });

  factory AvisModel.fromJson(Map<String, dynamic> json) {
    return AvisModel(
      id: json['id'] as String? ?? '',
      professeurId: json['professeurId'] as String? ?? '',
      note: (json['note'] as num?)?.toInt() ?? 0,
      commentaire: json['commentaire'] as String? ?? '',
      statut: AvisStatut.fromApi(json['statut'] as String? ?? 'VISIBLE'),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      auteurNom: json['auteurNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professeurId': professeurId,
      'note': note,
      'commentaire': commentaire,
      'statut': statut.apiValue,
      'createdAt': createdAt.toIso8601String(),
      if (auteurNom != null) 'auteurNom': auteurNom,
    };
  }

  /// Payload pour `POST /avis` : `{ professeurId, note, commentaire }`.
  static Map<String, dynamic> createJson({
    required String professeurId,
    required int note,
    required String commentaire,
  }) {
    return {
      'professeurId': professeurId,
      'note': note,
      'commentaire': commentaire,
    };
  }
}
