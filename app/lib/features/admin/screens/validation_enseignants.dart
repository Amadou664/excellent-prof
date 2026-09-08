import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/teacher_profile_model.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/teachers_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';

/// Validation / refus des candidatures enseignants (ADMIN). `GET
/// /teachers?statutCandidature=`, `PATCH /teachers/:id/candidature`.
class ValidationEnseignants extends ConsumerStatefulWidget {
  const ValidationEnseignants({super.key});

  @override
  ConsumerState<ValidationEnseignants> createState() => _ValidationEnseignantsState();
}

class _ValidationEnseignantsState extends ConsumerState<ValidationEnseignants> {
  StatutCandidature? _filter = StatutCandidature.soumise;

  @override
  Widget build(BuildContext context) {
    final filter = TeacherFilter(statutCandidature: _filter);
    final teachersAsync = ref.watch(teachersAdminProvider(filter));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              _FilterChip(label: 'Toutes', selected: _filter == null, onTap: () => setState(() => _filter = null)),
              ...StatutCandidature.values.map(
                (s) => _FilterChip(
                  label: s.label,
                  selected: _filter == s,
                  onTap: () => setState(() => _filter = s),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: teachersAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorState(
              error: e,
              onRetry: () => ref.invalidate(teachersAdminProvider(filter)),
            ),
            data: (teachers) {
              if (teachers.isEmpty) {
                return const EmptyState(
                  message: 'Aucune candidature ne correspond à ce filtre.',
                  icon: Icons.workspace_premium_outlined,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: teachers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _TeacherTile(
                  teacher: teachers[index],
                  onChanged: () => ref.invalidate(teachersAdminProvider(filter)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }
}

class _TeacherTile extends ConsumerStatefulWidget {
  const _TeacherTile({required this.teacher, required this.onChanged});

  final TeacherProfileModel teacher;
  final VoidCallback onChanged;

  @override
  ConsumerState<_TeacherTile> createState() => _TeacherTileState();
}

class _TeacherTileState extends ConsumerState<_TeacherTile> {
  late final TextEditingController _notesController;
  bool _isSaving = false;

  TeacherProfileModel get teacher => widget.teacher;
  VoidCallback get onChanged => widget.onChanged;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: teacher.notesVerification);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Affiche la pièce d'identité dans l'app plutôt que de l'ouvrir dans un
  /// navigateur externe : ce fichier est `sensible` côté backend (réservé
  /// aux ADMIN authentifiés), et `launchUrl` ne peut pas transmettre le
  /// token Firebase nécessaire.
  void _voirPieceIdentite(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: FutureBuilder<List<int>>(
          future: ref.read(fileRepositoryProvider).fetchProtectedBytes(teacher.pieceIdentiteUrl!),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text("Impossible de charger la pièce d'identité."),
              );
            }
            return InteractiveViewer(
              child: Image.memory(Uint8List.fromList(snapshot.data!)),
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateCandidature(StatutCandidature statut) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(teacherRepositoryProvider).updateCandidature(
            teacherId: teacher.id,
            statutCandidature: statut,
            notesVerification: _notesController.text.trim(),
          );
      onChanged();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de mettre à jour la candidature.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nom = teacher.user?.nomComplet ?? 'Professeur';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(nom, style: const TextStyle(fontWeight: FontWeight.bold))),
                StatusChip.candidature(teacher.statutCandidature),
              ],
            ),
            if (teacher.user?.ville.isNotEmpty ?? false)
              Text(teacher.user!.ville, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: teacher.specialites.map((s) => Chip(label: Text(s))).toList()),
            const SizedBox(height: 6),
            Text(teacher.bio, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  teacher.pieceIdentiteUrl != null ? Icons.verified_user_outlined : Icons.warning_amber,
                  size: 16,
                  color: teacher.pieceIdentiteUrl != null ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: teacher.pieceIdentiteUrl != null
                      ? OutlinedButton.icon(
                          onPressed: () => _voirPieceIdentite(context),
                          icon: const Icon(Icons.badge_outlined, size: 16),
                          label: const Text("Voir la pièce d'identité"),
                        )
                      : const Text(
                          "Pièce d'identité manquante — à ne pas valider sans vérification",
                          style: TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                ),
              ],
            ),
            if (teacher.diplomesUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${teacher.diplomesUrls.length} diplôme(s)/document(s) fourni(s) :',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  teacher.diplomesUrls.length,
                  (i) => OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(teacher.diplomesUrls[i]),
                      webOnlyWindowName: '_blank',
                    ),
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: Text('Document ${i + 1}'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note de vérification (ID contrôlée, référence contactée...)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : () => _updateCandidature(StatutCandidature.entretien),
                  child: const Text('Entretien'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _updateCandidature(StatutCandidature.validee),
                  child: const Text('Valider'),
                ),
                OutlinedButton(
                  onPressed: _isSaving ? null : () => _updateCandidature(StatutCandidature.refusee),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Refuser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
