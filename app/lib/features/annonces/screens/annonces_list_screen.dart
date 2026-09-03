import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/annonces_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Liste des annonces, consultable par tous (visiteurs voient `PUBLIC`,
/// connectés voient aussi `CONNECTES` — filtrage fait côté backend selon la
/// présence du header d'auth). `GET /annonces`.
class AnnoncesListScreen extends ConsumerWidget {
  const AnnoncesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annoncesAsync = ref.watch(annoncesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Annonces')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(annoncesProvider),
        child: annoncesAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(annoncesProvider)),
          data: (annonces) {
            if (annonces.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(message: 'Aucune annonce pour le moment.', icon: Icons.campaign_outlined),
                ],
              );
            }
            final sorted = [...annonces]..sort((a, b) => b.datePublication.compareTo(a.datePublication));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final annonce = sorted[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.paleGold,
                      child: Icon(_iconForType(annonce.type.apiValue), color: AppColors.primaryDarkGreen),
                    ),
                    title: Text(annonce.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${annonce.type.label} • ${DateFormat('dd/MM/yyyy').format(annonce.datePublication)}',
                    ),
                    onTap: () => context.push(AppRoutes.annonceDetailPath(annonce.id)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'RECRUTEMENT':
        return Icons.work_outline;
      case 'FORMATION':
        return Icons.school_outlined;
      case 'EVENEMENT':
        return Icons.event_outlined;
      case 'RESULTAT':
        return Icons.emoji_events_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
