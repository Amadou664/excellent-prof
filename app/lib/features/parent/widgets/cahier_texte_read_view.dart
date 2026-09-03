import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/seance_model.dart';
import '../../../providers/seances_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Vue en lecture seule du cahier de texte d'un élève, séance par séance.
///
/// Réutilisée par :
/// - `features/parent/screens/cahier_texte_view_screen.dart` (cahier de
///   texte d'un enfant) ;
/// - `features/learner/screens/mon_cahier_texte_screen.dart` (cahier de
///   texte de l'étudiant/particulier lui-même).
///
/// `GET /seances/mine` renvoie déjà les séances pertinentes pour
/// l'utilisateur connecté (voir API_CONTRACT.md) ; on filtre ici par
/// `studentId` pour n'afficher que celles de l'élève demandé.
class CahierTexteReadView extends ConsumerWidget {
  const CahierTexteReadView({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seancesAsync = ref.watch(seancesMineProvider);

    return seancesAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(seancesMineProvider),
      ),
      data: (seances) {
        final mine = seances.where((s) => s.studentId == studentId).toList()
          ..sort((a, b) => b.dateSeance.compareTo(a.dateSeance));

        if (mine.isEmpty) {
          return const EmptyState(
            message: "Aucune séance enregistrée pour l'instant.",
            icon: Icons.menu_book_outlined,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mine.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _SeanceCahierTile(seance: mine[index]),
        );
      },
    );
  }
}

class _SeanceCahierTile extends ConsumerWidget {
  const _SeanceCahierTile({required this.seance});

  final SeanceModel seance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = DateFormat('dd/MM/yyyy à HH:mm').format(seance.dateSeance);

    return Card(
      child: ExpansionTile(
        title: Text(
          seance.matiere ?? 'Séance',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(dateLabel),
        trailing: StatusChip.seanceStatut(seance.statut),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Consumer(
              builder: (context, ref, _) {
                final cahierAsync = ref.watch(cahierTexteProvider(seance.id));
                return cahierAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LoadingIndicator(),
                  ),
                  error: (e, _) => ErrorState(
                    error: e,
                    onRetry: () => ref.invalidate(cahierTexteProvider(seance.id)),
                  ),
                  data: (cahier) {
                    if (cahier == null || cahier.estVide) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Le professeur n'a pas encore rempli le cahier de "
                          "texte de cette séance.",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CahierSection(title: 'Contenu du cours', content: cahier.contenu),
                        _CahierSection(title: 'Exercices', content: cahier.exercices),
                        _CahierSection(title: 'Devoirs', content: cahier.devoirs),
                        _CahierSection(title: 'Observations', content: cahier.observations),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CahierSection extends StatelessWidget {
  const _CahierSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 2),
          Text(content),
        ],
      ),
    );
  }
}
