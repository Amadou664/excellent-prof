import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/students_provider.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../parent/widgets/demande_cours_form.dart';

/// Demande de cours pour soi-même (étudiant/particulier). Réutilise
/// [DemandeCoursForm] (partagé avec l'espace Parent) : comme `students` ne
/// contient qu'une seule entrée, le sélecteur d'élève est masqué
/// automatiquement.
class LearnerDemandeCoursScreen extends ConsumerWidget {
  const LearnerDemandeCoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsMineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Demande de cours')),
      body: SafeArea(
        child: studentsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(
            error: e,
            onRetry: () => ref.invalidate(studentsMineProvider),
          ),
          data: (students) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: DemandeCoursForm(students: students),
          ),
        ),
      ),
    );
  }
}
