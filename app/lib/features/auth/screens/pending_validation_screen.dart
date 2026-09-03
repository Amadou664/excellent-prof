import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/firebase_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Affiché à un compte PROFESSEUR tant que `User.status == EN_ATTENTE`
/// (candidature soumise, en attente d'entretien puis de validation par un
/// admin — voir `PATCH /teachers/:id/candidature` dans API_CONTRACT.md).
class PendingValidationScreen extends ConsumerWidget {
  const PendingValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidature en attente'),
        automaticallyImplyLeading: false,
      ),
      body: userAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (user) {
          final statut = user?.teacherProfile?.statutCandidature ?? StatutCandidature.soumise;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_top, size: 72, color: AppColors.gold),
                    const SizedBox(height: 20),
                    const Text(
                      'Votre candidature est en cours de traitement',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    StatusChip.candidature(statut),
                    const SizedBox(height: 20),
                    Text(
                      _messageForStatut(statut),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Actualiser le statut',
                      icon: Icons.refresh,
                      outlined: true,
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
          );
        },
      ),
    );
  }

  String _messageForStatut(StatutCandidature statut) {
    switch (statut) {
      case StatutCandidature.soumise:
        return "Votre dossier a bien été reçu. Notre équipe va l'examiner et "
            "vous contactera pour un entretien.";
      case StatutCandidature.entretien:
        return "Un entretien est en cours d'organisation avec notre équipe "
            "de recrutement.";
      case StatutCandidature.refusee:
        return "Votre candidature n'a malheureusement pas été retenue pour "
            "le moment.";
      case StatutCandidature.validee:
        return 'Votre candidature est validée, vous allez être redirigé.';
    }
  }
}
