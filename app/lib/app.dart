import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_providers.dart';
import 'providers/fcm_provider.dart';

/// Racine de l'application : branche `go_router` (via [goRouterProvider])
/// sur un `MaterialApp.router`, et synchronise le token FCM dès qu'un
/// profil utilisateur complet est disponible.
class ExcellentProfApp extends ConsumerStatefulWidget {
  const ExcellentProfApp({super.key});

  @override
  ConsumerState<ExcellentProfApp> createState() => _ExcellentProfAppState();
}

class _ExcellentProfAppState extends ConsumerState<ExcellentProfApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // Par défaut, FCM n'affiche automatiquement une notification système que
    // lorsque l'app est en arrière-plan/fermée. Au premier plan, on affiche
    // nous-mêmes un SnackBar pour ne pas perdre l'information (ex: nouveau
    // message, demande assignée...).
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            [notification.title, notification.body]
                .where((s) => s != null && s.isNotEmpty)
                .join(' — '),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dès que le profil utilisateur complet est chargé, on synchronise le
    // token FCM côté backend (`POST /auth/fcm-token`). Volontairement
    // "fire-and-forget" et silencieux en cas d'échec (voir fcm_provider.dart).
    ref.listen(currentUserProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        syncFcmToken(ref);
      }
    });

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
    );
  }
}
