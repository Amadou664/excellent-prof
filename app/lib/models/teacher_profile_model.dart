import 'enums.dart';

/// Mini-objet utilisateur imbriqué dans `TeacherProfile.user`.
class TeacherProfileUserInfo {
  final String nom;
  final String prenom;
  final String ville;
  final String? photoUrl;

  const TeacherProfileUserInfo({
    required this.nom,
    required this.prenom,
    required this.ville,
    this.photoUrl,
  });

  String get nomComplet => '$prenom $nom';

  factory TeacherProfileUserInfo.fromJson(Map<String, dynamic> json) {
    return TeacherProfileUserInfo(
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      ville: json['ville'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nom': nom, 'prenom': prenom, 'ville': ville, 'photoUrl': photoUrl};
  }
}

/// Correspond au schéma `TeacherProfile` d'API_CONTRACT.md.
///
/// ```json
/// {
///   "id": "uuid", "userId": "uuid", "specialites": ["string"], "diplomesUrls": ["string"],
///   "bio": "string", "zoneGeo": "string", "disponibilites": { "lundi": ["18:00-20:00"], "...": [] },
///   "statutCandidature": "StatutCandidature", "noteMoyenne": 4.5, "nombreAvis": 12,
///   "user": { "nom": "string", "prenom": "string", "ville": "string", "photoUrl": "string|null" }
/// }
/// ```
class TeacherProfileModel {
  final String id;
  final String userId;
  final List<String> specialites;
  final List<String> diplomesUrls;
  final String bio;
  final String zoneGeo;

  /// Ex: `{"lundi": ["18:00-20:00"], "mardi": []}`.
  final Map<String, List<String>> disponibilites;
  final StatutCandidature statutCandidature;
  final double noteMoyenne;
  final int nombreAvis;
  final TeacherProfileUserInfo? user;

  const TeacherProfileModel({
    required this.id,
    required this.userId,
    required this.specialites,
    required this.diplomesUrls,
    required this.bio,
    required this.zoneGeo,
    required this.disponibilites,
    required this.statutCandidature,
    required this.noteMoyenne,
    required this.nombreAvis,
    this.user,
  });

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    final disposRaw =
        json['disponibilites'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return TeacherProfileModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      specialites:
          (json['specialites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      diplomesUrls:
          (json['diplomesUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      bio: json['bio'] as String? ?? '',
      zoneGeo: json['zoneGeo'] as String? ?? '',
      disponibilites: disposRaw.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>? ?? <dynamic>[])
              .map((e) => e.toString())
              .toList(),
        ),
      ),
      statutCandidature: StatutCandidature.fromApi(
        json['statutCandidature'] as String? ?? 'SOUMISE',
      ),
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
      user: json['user'] != null
          ? TeacherProfileUserInfo.fromJson(
              json['user'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'specialites': specialites,
      'diplomesUrls': diplomesUrls,
      'bio': bio,
      'zoneGeo': zoneGeo,
      'disponibilites': disponibilites,
      'statutCandidature': statutCandidature.apiValue,
      'noteMoyenne': noteMoyenne,
      'nombreAvis': nombreAvis,
      'user': user?.toJson(),
    };
  }

  /// Payload pour `PATCH /teachers/me` : `{ specialites?, bio?, disponibilites?, zoneGeo? }`.
  static Map<String, dynamic> updateJson({
    List<String>? specialites,
    String? bio,
    Map<String, List<String>>? disponibilites,
    String? zoneGeo,
  }) {
    final map = <String, dynamic>{};
    if (specialites != null) map['specialites'] = specialites;
    if (bio != null) map['bio'] = bio;
    if (disponibilites != null) map['disponibilites'] = disponibilites;
    if (zoneGeo != null) map['zoneGeo'] = zoneGeo;
    return map;
  }
}
