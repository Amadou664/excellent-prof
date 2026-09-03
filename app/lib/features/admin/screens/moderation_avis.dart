import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/avis_model.dart';
import '../../../models/enums.dart';
import '../../../providers/avis_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Modération des avis (ADMIN). `PATCH /avis/:id/statut`, `DELETE /avis/:id`.
class ModerationAvis extends ConsumerWidget {
  const ModerationAvis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avisAsync = ref.watch(avisAllProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(avisAllProvider),
      child: avisAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(avisAllProvider)),
        data: (avisList) {
          if (avisList.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(message: 'Aucun avis à modérer.', icon: Icons.reviews_outlined),
              ],
            );
          }
          final sorted = [...avisList]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _AvisTile(
              avis: sorted[index],
              onChanged: () => ref.invalidate(avisAllProvider),
            ),
          );
        },
      ),
    );
  }
}

class _AvisTile extends ConsumerWidget {
  const _AvisTile({required this.avis, required this.onChanged});

  final AvisModel avis;
  final VoidCallback onChanged;

  Future<void> _toggleStatut(BuildContext context, WidgetRef ref) async {
    final nouveauStatut = avis.statut == AvisStatut.visible ? AvisStatut.masque : AvisStatut.visible;
    try {
      await ref.read(avisRepositoryProvider).updateStatut(id: avis.id, statut: nouveauStatut);
      onChanged();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action impossible.')));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet avis ?'),
        content: Text(avis.commentaire),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(avisRepositoryProvider).delete(avis.id);
      onChanged();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suppression impossible.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < avis.note ? Icons.star : Icons.star_border,
                      color: AppColors.gold,
                      size: 16,
                    ),
                  ),
                ),
                const Spacer(),
                StatusChip.avisStatut(avis.statut),
              ],
            ),
            const SizedBox(height: 6),
            Text(avis.commentaire),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy').format(avis.createdAt),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _toggleStatut(context, ref),
                  child: Text(avis.statut == AvisStatut.visible ? 'Masquer' : 'Rendre visible'),
                ),
                OutlinedButton(
                  onPressed: () => _delete(context, ref),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
