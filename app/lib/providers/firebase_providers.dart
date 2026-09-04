import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase/auth_service.dart';
import '../core/firebase/messaging_service.dart';

/// Instances brutes des SDK Firebase. Centralisées ici pour rester faciles à
/// substituer dans des tests (`overrideWithValue`).
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firebaseMessagingProvider = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);

final messagingServiceProvider = Provider<MessagingService>(
  (ref) => MessagingService(ref.watch(firebaseMessagingProvider)),
);
