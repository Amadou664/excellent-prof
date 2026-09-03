import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_providers.dart';
import 'repository_providers.dart';

/// Demande la permission de notification, récupère le token FCM courant et
/// l'enregistre côté backend via `POST /auth/fcm-token`.
///
/// Volontairement tolérant aux erreurs : l'absence de notifications push
/// n'est pas bloquante pour l'usage de l'application (ex: Firebase pas
/// encore configuré via `flutterfire configure`, permission refusée...).
Future<void> syncFcmToken(WidgetRef ref) async {
  try {
    final messaging = ref.read(messagingServiceProvider);
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await ref.read(authRepositoryProvider).sendFcmToken(token);
    }
  } catch (_) {
    // Silencieux par design, voir doc ci-dessus.
  }
}
