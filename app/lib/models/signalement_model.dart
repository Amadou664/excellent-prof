/// Mini-infos utilisateur imbriquées dans un signalement (auteur/cible).
class SignalementUserInfo {
  final String nom;
  final String prenom;
  final String email;

  const SignalementUserInfo({required this.nom, required this.prenom, required this.email});

  String get nomComplet => '$prenom $nom';

  factory SignalementUserInfo.fromJson(Map<String, dynamic> json) {
    return SignalementUserInfo(
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

/// `GET /signalements` (ADMIN).
class SignalementModel {
  final String id;
  final String motif;
  final String statut;
  final DateTime createdAt;
  final SignalementUserInfo? auteur;
  final SignalementUserInfo? cible;

  const SignalementModel({
    required this.id,
    required this.motif,
    required this.statut,
    required this.createdAt,
    this.auteur,
    this.cible,
  });

  bool get estTraite => statut == 'TRAITE';

  factory SignalementModel.fromJson(Map<String, dynamic> json) {
    return SignalementModel(
      id: json['id'] as String,
      motif: json['motif'] as String? ?? '',
      statut: json['statut'] as String? ?? 'NOUVEAU',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      auteur: json['auteur'] != null
          ? SignalementUserInfo.fromJson(json['auteur'] as Map<String, dynamic>)
          : null,
      cible: json['cible'] != null
          ? SignalementUserInfo.fromJson(json['cible'] as Map<String, dynamic>)
          : null,
    );
  }
}
