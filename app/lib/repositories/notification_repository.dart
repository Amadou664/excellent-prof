import '../core/network/api_client.dart';
import '../models/notification_model.dart';

/// Domaine `/notifications` : centre de notifications persistant (voir
/// `backend/src/utils/push.ts`).
class NotificationRepository {
  NotificationRepository(this._client);

  final ApiClient _client;

  /// `GET /notifications/mine`.
  Future<NotificationsPage> listMine() async {
    final data = await _client.unwrap(() => _client.dio.get('/notifications/mine'));
    return NotificationsPage.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /notifications/:id/read`.
  Future<void> markRead(String id) async {
    await _client.unwrap(() => _client.dio.patch('/notifications/$id/read'));
  }

  /// `PATCH /notifications/read-all`.
  Future<void> markAllRead() async {
    await _client.unwrap(() => _client.dio.patch('/notifications/read-all'));
  }
}
