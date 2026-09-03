import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/firebase_providers.dart';
import '../../../widgets/app_button.dart';

/// Affiché quand `GET /auth/me` échoue pour une raison autre qu'un profil
/// manquant (404) — typiquement le backend est injoignable. Propose de
/// réessayer ou de se déconnecter pour revenir à l'écran de sélection de
/// profil.
class ConnectionErrorScreen extends ConsumerWidget {
  const ConnectionErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Impossible de joindre le serveur.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Vérifiez votre connexion internet, ou que l'adresse de "
                  "l'API (lib/core/constants.dart) est correcte.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Réessayer',
                  icon: Icons.refresh,
                  onPressed: () => ref.invalidate(currentUserProvider),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Se déconnecter',
                  outlined: true,
                  onPressed: () => ref.read(authServiceProvider).signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
