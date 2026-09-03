import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/student_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/students_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Liste des enfants du parent connecté (`GET /students/mine`).
class MesEnfantsScreen extends ConsumerWidget {
  const MesEnfantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsMineProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(studentsMineProvider),
      child: studentsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(studentsMineProvider),
        ),
        data: (students) {
          if (students.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(
                  message: "Vous n'avez pas encore ajouté d'enfant.",
                  icon: Icons.family_restroom,
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _ChildCard(student: students[index]),
          );
        },
      ),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  const _ChildCard({required this.student});

  final StudentModel student;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet élève ?'),
        content: Text('${student.nomComplet} sera définitivement supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(studentRepositoryProvider).delete(student.id);
      ref.invalidate(studentsMineProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression impossible.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppColors.paleGold,
          child: Text(
            student.prenom.isNotEmpty ? student.prenom[0].toUpperCase() : '?',
            style: const TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.nomComplet, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${student.niveau.label} • ${student.programme.label}\n'
          'Né(e) le ${DateFormat('dd/MM/yyyy').format(student.dateNaissance)}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'cahier') {
              context.push(AppRoutes.parentCahierTextePath(student.id));
            } else if (value == 'delete') {
              _confirmDelete(context, ref);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'cahier', child: Text('Cahier de texte')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
        onTap: () => context.push(AppRoutes.parentCahierTextePath(student.id)),
      ),
    );
  }
}
