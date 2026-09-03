import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/students_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../parent/widgets/cahier_texte_read_view.dart';

/// Cahier de texte de l'étudiant/particulier lui-même. Réutilise
/// [CahierTexteReadView] (partagé avec l'espace Parent) en résolvant
/// d'abord son propre `Student` via `GET /students/mine`.
class MonCahierTexteScreen extends ConsumerWidget {
  const MonCahierTexteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsMineProvider);

    return studentsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(studentsMineProvider),
      ),
      data: (students) {
        if (students.isEmpty) {
          return const EmptyState(
            message: 'Votre profil élève est introuvable.',
            icon: Icons.menu_book_outlined,
          );
        }
        return CahierTexteReadView(studentId: students.first.id);
      },
    );
  }
}
