import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/signalement_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/signalement_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Liste des signalements (ADMIN). `GET /signalements`,
/// `PATCH /signalements/:id/traiter`.
class GestionSignalements extends ConsumerWidget {
  const GestionSignalements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalementsAsync = ref.watch(signalementsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(signalementsProvider),
      child: signalementsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(signalementsProvider)),
        data: (signalements) {
          if (signalements.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(message: 'Aucun signalement pour le moment.', icon: Icons.flag_outlined),
              ],
            );
          }
          final sorted = [...signalements]..sort((a, b) {
            if (a.estTraite != b.estTraite) return a.estTraite ? 1 : -1;
            return b.createdAt.compareTo(a.createdAt);
          });
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _SignalementTile(
              signalement: sorted[index],
              onChanged: () => ref.invalidate(signalementsProvider),
            ),
          );
        },
      ),
    );
  }
}

class _SignalementTile extends ConsumerWidget {
  const _SignalementTile({required this.signalement, required this.onChanged});

  final SignalementModel signalement;
  final VoidCallback onChanged;

  Future<void> _marquerTraite(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(signalementRepositoryProvider).markTraite(signalement.id);
      onChanged();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action impossible.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estTraite = signalement.estTraite;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 16,
                  color: estTraite ? AppColors.textSecondary : AppColors.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    signalement.cible?.nomComplet ?? 'Utilisateur supprimé',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: estTraite ? Colors.grey.shade200 : AppColors.paleGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estTraite ? 'Traité' : 'Nouveau',
                    style: TextStyle(
                      fontSize: 11,
                      color: estTraite ? AppColors.textSecondary : AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Signalé par : ${signalement.auteur?.nomComplet ?? 'inconnu'} (${signalement.auteur?.email ?? '—'})',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(signalement.motif),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(signalement.createdAt),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            if (!estTraite) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _marquerTraite(context, ref),
                child: const Text('Marquer comme traité'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
