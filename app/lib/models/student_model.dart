import 'enums.dart';

/// Correspond au schéma `Student` d'API_CONTRACT.md.
///
/// ```json
/// {
///   "id": "uuid", "nom": "string", "prenom": "string", "dateNaissance": "ISO date",
///   "niveau": "Niveau", "programme": "Programme", "parentId": "uuid|null", "userId": "uuid|null"
/// }
/// ```
class StudentModel {
  final String id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final Niveau niveau;
  final Programme programme;

  /// Non nul quand ce `Student` est l'enfant d'un `PARENT`.
  final String? parentId;

  /// Non nul quand ce `Student` est le profil d'un ETUDIANT/PARTICULIER
  /// autonome (lié directement à son propre `User`).
  final String? userId;

  const StudentModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.niveau,
    required this.programme,
    this.parentId,
    this.userId,
  });

  String get nomComplet => '$prenom $nom';

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      dateNaissance:
          DateTime.tryParse(json['dateNaissance'] as String? ?? '') ??
          DateTime.now(),
      niveau: Niveau.fromApi(json['niveau'] as String? ?? 'FONDAMENTAL'),
      programme: Programme.fromApi(json['programme'] as String? ?? 'MALIEN'),
      parentId: json['parentId'] as String?,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance.toIso8601String(),
      'niveau': niveau.apiValue,
      'programme': programme.apiValue,
      'parentId': parentId,
      'userId': userId,
    };
  }

  /// Payload minimal attendu par `POST /students` : `{ nom, prenom, dateNaissance, niveau, programme }`.
  Map<String, dynamic> toCreateJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance.toIso8601String(),
      'niveau': niveau.apiValue,
      'programme': programme.apiValue,
    };
  }
}
