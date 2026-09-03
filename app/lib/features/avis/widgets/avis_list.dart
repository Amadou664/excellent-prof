import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/avis_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Liste des avis visibles d'un professeur. `GET /avis?professeurId=`.
class AvisList extends ConsumerWidget {
  const AvisList({super.key, required this.professeurId, this.shrinkWrap = true});

  final String professeurId;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avisAsync = ref.watch(avisByProfesseurProvider(professeurId));

    return avisAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(avisByProfesseurProvider(professeurId)),
      ),
      data: (avisList) {
        if (avisList.isEmpty) {
          return const EmptyState(
            message: 'Aucun avis pour le moment.',
            icon: Icons.reviews_outlined,
          );
        }
        return ListView.separated(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          itemCount: avisList.length,
          separatorBuilder: (_, _) => const Divider(height: 20),
          itemBuilder: (context, index) {
            final avis = avisList[index];
            return Column(
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
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(avis.createdAt),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (avis.auteurNom != null)
                  Text(avis.auteurNom!, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(avis.commentaire),
              ],
            );
          },
        );
      },
    );
  }
}
