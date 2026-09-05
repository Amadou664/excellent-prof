import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import 'repository_providers.dart';

/// `GET /notifications/mine`.
final notificationsProvider = FutureProvider.autoDispose<NotificationsPage>((ref) {
  return ref.watch(notificationRepositoryProvider).listMine();
});
