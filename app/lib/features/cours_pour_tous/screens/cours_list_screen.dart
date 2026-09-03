import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/cours_pour_tous_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Liste des campagnes "cours pour tous" à venir. `GET /cours-pour-tous`.
class CoursListScreen extends ConsumerWidget {
  const CoursListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursAsync = ref.watch(coursPourTousProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cours pour tous')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(coursPourTousProvider),
        child: coursAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(coursPourTousProvider)),
          data: (cours) {
            if (cours.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(message: 'Aucune campagne prévue pour le moment.', icon: Icons.diversity_3_outlined),
                ],
              );
            }
            final sorted = [...cours]..sort((a, b) => a.dateDebut.compareTo(b.dateDebut));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = sorted[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    title: Text(c.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${c.matiere} • ${c.tarif} FCFA\n'
                      'Du ${DateFormat('dd/MM/yyyy').format(c.dateDebut)} au ${DateFormat('dd/MM/yyyy').format(c.dateFin)}',
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${c.placesRestantes}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: c.complet ? AppColors.error : AppColors.success,
                          ),
                        ),
                        const Text('places', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    onTap: () => context.push(AppRoutes.coursPourTousDetailPath(c.id)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
