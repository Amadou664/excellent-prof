import 'enums.dart';

/// Correspond au schéma `Annonce` d'API_CONTRACT.md.
///
/// ```json
/// { "id": "uuid", "titre": "string", "contenu": "string", "type": "AnnonceType",
///   "visibilite": "Visibilite", "imageUrl": "string|null", "datePublication": "ISO datetime" }
/// ```
class AnnonceModel {
  final String id;
  final String titre;
  final String contenu;
  final AnnonceType type;
  final Visibilite visibilite;
  final String? imageUrl;
  final DateTime datePublication;

  const AnnonceModel({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.type,
    required this.visibilite,
    this.imageUrl,
    required this.datePublication,
  });

  factory AnnonceModel.fromJson(Map<String, dynamic> json) {
    return AnnonceModel(
      id: json['id'] as String,
      titre: json['titre'] as String? ?? '',
      contenu: json['contenu'] as String? ?? '',
      type: AnnonceType.fromApi(json['type'] as String? ?? 'INFO'),
      visibilite: Visibilite.fromApi(
        json['visibilite'] as String? ?? 'PUBLIC',
      ),
      imageUrl: json['imageUrl'] as String?,
      datePublication:
          DateTime.tryParse(json['datePublication'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'type': type.apiValue,
      'visibilite': visibilite.apiValue,
      'imageUrl': imageUrl,
      'datePublication': datePublication.toIso8601String(),
    };
  }

  /// Payload pour `POST /annonces` / `PATCH /annonces/:id`.
  static Map<String, dynamic> writeJson({
    required String titre,
    required String contenu,
    required AnnonceType type,
    required Visibilite visibilite,
    String? imageUrl,
  }) {
    return {
      'titre': titre,
      'contenu': contenu,
      'type': type.apiValue,
      'visibilite': visibilite.apiValue,
      'imageUrl': imageUrl,
    };
  }
}
