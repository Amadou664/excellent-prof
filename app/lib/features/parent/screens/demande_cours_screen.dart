import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/students_provider.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../widgets/demande_cours_form.dart';

/// Écran de demande de cours (réservation) pour un des enfants du parent.
/// Le formulaire propose un sélecteur d'enfant lorsqu'il y en a plusieurs
/// (voir [DemandeCoursForm]).
class DemandeCoursScreen extends ConsumerWidget {
  const DemandeCoursScreen({super.key, this.preselectedStudentId});

  final String? preselectedStudentId;

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
            child: DemandeCoursForm(
              students: students,
              preselectedStudentId: preselectedStudentId,
            ),
          ),
        ),
      ),
    );
  }
}
