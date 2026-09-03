import 'package:firebase_messaging/firebase_messaging.dart';

/// Fine couche au-dessus de `firebase_messaging`.
///
/// Ne contacte PAS l'API elle-même : elle expose uniquement le token FCM
/// courant et ses rafraîchissements. C'est au provider applicatif
/// (`providers/fcm_provider.dart`) de transmettre ce token au backend via
/// `POST /auth/fcm-token`, une fois l'utilisateur authentifié.
class MessagingService {
  MessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  /// Demande les permissions de notification (obligatoire sur iOS, no-op
  /// silencieux sur Android < 13, demande la permission runtime sur
  /// Android 13+).
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
