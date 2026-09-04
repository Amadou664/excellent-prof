import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../models/demande_model.dart';
import '../../../models/enums.dart';
import '../../../providers/demandes_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';
import '../../avis/widgets/avis_form.dart';

/// Liste des demandes de cours de l'utilisateur courant (`GET
/// /demandes/mine`), avec possibilité d'annuler une demande active ou de
/// laisser un avis une fois la demande `TERMINEE`.
///
/// Réutilisé par l'espace Parent et l'espace Étudiant/Particulier (les deux
/// utilisent la même route `/demandes/mine` scoping automatiquement côté
/// backend selon l'utilisateur connecté).
class DemandesListView extends ConsumerWidget {
  const DemandesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandesAsync = ref.watch(demandesMineProvider);

    return demandesAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(demandesMineProvider),
      ),
      data: (demandes) {
        if (demandes.isEmpty) {
          return const EmptyState(
            message: 'Aucune demande de cours pour le moment.',
            icon: Icons.assignment_outlined,
          );
        }
        final sorted = [...demandes]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _DemandeTile(demande: sorted[index]),
        );
      },
    );
  }
}

class _DemandeTile extends ConsumerWidget {
  const _DemandeTile({required this.demande});

  final DemandeModel demande;

  Future<void> _annuler(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la demande ?'),
        content: Text('Voulez-vous annuler la demande "${demande.matiere}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui, annuler')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(demandeRepositoryProvider).annuler(demande.id);
      ref.invalidate(demandesMineProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'annuler la demande.")),
        );
      }
    }
  }

  void _laisserUnAvis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: AvisForm(
          professeurId: demande.professeurId!,
          onSubmitted: () => Navigator.pop(context),
        ),
      ),
    );
  }

  bool get _peutEtreAnnulee =>
      demande.status == DemandeStatus.nouvelle ||
      demande.status == DemandeStatus.profPropose ||
      demande.status == DemandeStatus.confirmee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    demande.matiere,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                StatusChip.demandeStatus(demande.status),
              ],
            ),
            const SizedBox(height: 6),
            Text('Mode : ${demande.modePref.label}'),
            Text(
              'Créée le ${DateFormat('dd/MM/yyyy').format(demande.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (demande.notes != null && demande.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(demande.notes!),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (demande.professeurId != null && demande.status != DemandeStatus.annulee)
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.chatPath(demande.id)),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Discuter'),
                  ),
                if (_peutEtreAnnulee)
                  OutlinedButton(
                    onPressed: () => _annuler(context, ref),
                    child: const Text('Annuler'),
                  ),
                if (demande.status == DemandeStatus.terminee && demande.professeurId != null)
                  ElevatedButton.icon(
                    onPressed: () => _laisserUnAvis(context),
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Laisser un avis'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
