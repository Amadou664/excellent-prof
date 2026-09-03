import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/cours_pour_tous_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Détail d'une campagne "cours pour tous".
///
/// NOTE : comme pour les annonces, API_CONTRACT.md ne documente pas de `GET
/// /cours-pour-tous/:id` dédié — on récupère la liste et on filtre par [id].
class CoursDetailScreen extends ConsumerWidget {
  const CoursDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursAsync = ref.watch(coursPourTousProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la campagne')),
      body: coursAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(coursPourTousProvider)),
        data: (coursList) {
          final match = coursList.where((c) => c.id == id);
          if (match.isEmpty) {
            return const EmptyState(message: 'Campagne introuvable.', icon: Icons.error_outline);
          }
          final cours = match.first;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cours.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(cours.matiere, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.calendar_today_outlined, label: 'Début', value: DateFormat('dd/MM/yyyy').format(cours.dateDebut)),
                _InfoRow(icon: Icons.event_outlined, label: 'Fin', value: DateFormat('dd/MM/yyyy').format(cours.dateFin)),
                _InfoRow(icon: Icons.payments_outlined, label: 'Tarif', value: '${cours.tarif} FCFA'),
                _InfoRow(
                  icon: Icons.event_seat_outlined,
                  label: 'Places',
                  value: '${cours.placesRestantes} / ${cours.placesDisponibles} restantes',
                ),
                const SizedBox(height: 16),
                Text(cours.description, style: const TextStyle(fontSize: 15, height: 1.5)),
                const SizedBox(height: 24),
                if (cours.complet)
                  const Text(
                    'Cette campagne est complète.',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  )
                else
                  AppButton(
                    label: "S'inscrire",
                    onPressed: () => context.push(AppRoutes.coursPourTousInscriptionPath(cours.id)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label : ', style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
