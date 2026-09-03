import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/teachers_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/inline_error_banner.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/status_chip.dart';
import '../../avis/widgets/avis_list.dart';

/// Statut de candidature du professeur + édition de son profil public
/// (spécialités, bio). `GET /teachers/me`, `PATCH /teachers/me`.
class ProfilCandidatureScreen extends ConsumerStatefulWidget {
  const ProfilCandidatureScreen({super.key});

  @override
  ConsumerState<ProfilCandidatureScreen> createState() => _ProfilCandidatureScreenState();
}

class _ProfilCandidatureScreenState extends ConsumerState<ProfilCandidatureScreen> {
  final _bioController = TextEditingController();
  final _specialiteInputController = TextEditingController();
  List<String> _specialites = [];

  bool _prefilled = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _bioController.dispose();
    _specialiteInputController.dispose();
    super.dispose();
  }

  void _prefill(List<String> specialites, String bio) {
    if (_prefilled) return;
    _specialites = [...specialites];
    _bioController.text = bio;
    _prefilled = true;
  }

  void _addSpecialite() {
    final value = _specialiteInputController.text.trim();
    if (value.isEmpty) return;
    if (!_specialites.contains(value)) {
      setState(() => _specialites.add(value));
    }
    _specialiteInputController.clear();
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ref.read(teacherRepositoryProvider).updateMe(
            specialites: _specialites,
            bio: _bioController.text.trim(),
          );
      ref.invalidate(teacherMeProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour.')),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Impossible de mettre à jour votre profil.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherAsync = ref.watch(teacherMeProvider);

    return teacherAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(teacherMeProvider),
      ),
      data: (teacher) {
        _prefill(teacher.specialites, teacher.bio);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: StatusChip.candidature(teacher.statutCandidature)),
              const SizedBox(height: 8),
              if (teacher.statutCandidature == StatutCandidature.refusee)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    "Votre candidature n'a pas été retenue. Contactez notre "
                    "équipe pour plus d'informations.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.gold, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${teacher.noteMoyenne.toStringAsFixed(1)} (${teacher.nombreAvis} avis)',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                InlineErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              const Text('Spécialités', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Ajouter une spécialité',
                      controller: _specialiteInputController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _addSpecialite, icon: const Icon(Icons.add)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specialites
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        onDeleted: () => setState(() => _specialites.remove(s)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Bio / présentation',
                controller: _bioController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppButton(label: 'Enregistrer', isLoading: _isSaving, onPressed: _submit),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Avis de mes élèves', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              AvisList(professeurId: teacher.id),
            ],
          ),
        );
      },
    );
  }
}
