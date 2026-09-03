import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../models/enums.dart';
import '../../../models/seance_model.dart';
import '../../../providers/demandes_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/seances_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Espace Professeur — liste des séances (élèves) assignées, plus les
/// éventuelles demandes qui lui ont été proposées (`PROF_PROPOSE`) en
/// attente de confirmation.
///
/// NOTE (voir README/rapport) : API_CONTRACT.md documente `GET
/// /demandes/mine` comme "demandes de l'utilisateur courant (via ses
/// students)", pensé pour PARENT/ETUDIANT/PARTICULIER. Il n'existe pas
/// d'endpoint documenté pour qu'un PROFESSEUR découvre les demandes qui lui
/// ont été proposées (`PROF_PROPOSE`) avant de les confirmer via `PATCH
/// /demandes/:id/confirmer`. On réutilise ici `/demandes/mine` en supposant
/// qu'il est étendu côté backend pour renvoyer aussi les demandes où
/// `professeurId == moi` ; si ce n'est pas le cas, cette section reste
/// simplement vide (dégradation silencieuse, pas de crash).
class MesElevesScreen extends ConsumerWidget {
  const MesElevesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seancesAsync = ref.watch(seancesMineProvider);
    final demandesAsync = ref.watch(demandesMineProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(seancesMineProvider);
        ref.invalidate(demandesMineProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          demandesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (demandes) {
              final aConfirmer = demandes
                  .where((d) => d.status == DemandeStatus.profPropose)
                  .toList();
              if (aConfirmer.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demandes à confirmer',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...aConfirmer.map((d) => _DemandeAConfirmerTile(demande: d)),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
          const Text(
            'Mes séances',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          seancesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: LoadingIndicator(),
            ),
            error: (e, _) => ErrorState(
              error: e,
              onRetry: () => ref.invalidate(seancesMineProvider),
            ),
            data: (seances) {
              if (seances.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    message: 'Aucune séance assignée pour le moment.',
                    icon: Icons.groups_outlined,
                  ),
                );
              }
              final sorted = [...seances]..sort((a, b) => b.dateSeance.compareTo(a.dateSeance));
              return Column(
                children: sorted.map((s) => _SeanceTile(seance: s)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DemandeAConfirmerTile extends ConsumerWidget {
  const _DemandeAConfirmerTile({required this.demande});

  final DemandeModel demande;

  Future<void> _confirmer(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(demandeRepositoryProvider).confirmer(demande.id);
      ref.invalidate(demandesMineProvider);
      ref.invalidate(seancesMineProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de confirmer cette demande.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.paleGold.withValues(alpha: 0.4),
      child: ListTile(
        title: Text(demande.matiere),
        subtitle: Text('Mode : ${demande.modePref.label}'),
        trailing: ElevatedButton(
          onPressed: () => _confirmer(context, ref),
          child: const Text('Confirmer'),
        ),
      ),
    );
  }
}

class _SeanceTile extends StatelessWidget {
  const _SeanceTile({required this.seance});

  final SeanceModel seance;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy à HH:mm').format(seance.dateSeance);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(seance.matiere ?? 'Séance', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(dateLabel),
        trailing: StatusChip.seanceStatut(seance.statut),
        onTap: () => context.push(AppRoutes.teacherCahierTexteEditPath(seance.id)),
      ),
    );
  }
}
