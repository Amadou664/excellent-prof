import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Dashboard de statistiques admin. `GET /admin/stats`.
class AdminDashboardStats extends ConsumerWidget {
  const AdminDashboardStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminStatsProvider),
      child: statsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(adminStatsProvider),
        ),
        data: (stats) {
          final cards = [
            _StatCardData('Enseignants validés', stats.enseignantsValides.toString(), Icons.verified_outlined, AppColors.success),
            _StatCardData('Candidatures en attente', stats.enseignantsEnAttente.toString(), Icons.hourglass_top, AppColors.warning),
            _StatCardData('Familles clientes', stats.famillesClientes.toString(), Icons.family_restroom, AppColors.info),
            _StatCardData('Élèves inscrits', stats.elevesInscrits.toString(), Icons.school_outlined, AppColors.primaryGreen),
            _StatCardData('Demandes en cours', stats.demandesEnCours.toString(), Icons.assignment_outlined, AppColors.lightGreen),
            _StatCardData('Avis à modérer', stats.avisEnAttenteModeration.toString(), Icons.reviews_outlined, AppColors.error),
            _StatCardData(
              "Chiffre d'affaires",
              '${stats.chiffreAffaires} FCFA',
              Icons.payments_outlined,
              AppColors.primaryDarkGreen,
            ),
            _StatCardData(
              'Taux de fidélisation',
              '${stats.tauxFidelisation.toStringAsFixed(0)} %',
              Icons.loop,
              AppColors.info,
            ),
          ];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) => _StatCard(data: cards[index]),
          );
        },
      ),
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCardData(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(data.icon, color: data.color, size: 28),
            Text(
              data.value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: data.color),
            ),
            Text(
              data.label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
