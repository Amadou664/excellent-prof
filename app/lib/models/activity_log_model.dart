/// `GET /activity` (ADMIN) : une ligne du journal d'activité — soit une
/// requête API reçue par le serveur, soit une vue d'écran envoyée par
/// l'application (`method == 'VUE'`).
class ActivityLogModel {
  final String id;
  final String? userId;
  final String? utilisateur;
  final String? role;
  final String method;
  final String path;
  final int? statusCode;
  final DateTime createdAt;

  const ActivityLogModel({
    required this.id,
    this.userId,
    this.utilisateur,
    this.role,
    required this.method,
    required this.path,
    this.statusCode,
    required this.createdAt,
  });

  bool get estUneVue => method == 'VUE';
  bool get estUneErreur => statusCode != null && statusCode! >= 400;

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      utilisateur: json['utilisateur'] as String?,
      role: json['role'] as String?,
      method: json['method'] as String? ?? '',
      path: json['path'] as String? ?? '',
      statusCode: json['statusCode'] as int?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
