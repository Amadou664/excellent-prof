/// `GET /notifications/mine` (item individuel).
class NotificationModel {
  final String id;
  final String titre;
  final String corps;
  final bool lue;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.titre,
    required this.corps,
    required this.lue,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      titre: json['titre'] as String? ?? '',
      corps: json['corps'] as String? ?? '',
      lue: json['lue'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Réponse complète de `GET /notifications/mine` : `{ items, unreadCount }`.
class NotificationsPage {
  final List<NotificationModel> items;
  final int unreadCount;

  const NotificationsPage({required this.items, required this.unreadCount});

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    return NotificationsPage(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
