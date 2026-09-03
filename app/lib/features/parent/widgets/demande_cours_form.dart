import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/enums.dart';
import '../../../models/student_model.dart';
import '../../../providers/demandes_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/inline_error_banner.dart';

/// Formulaire de demande de cours (réservation), `POST /demandes` body
/// `{ studentId, matiere, modePref, notes? }`.
///
/// Réutilisé par :
/// - `features/parent/screens/demande_cours_screen.dart` (le parent choisit
///   pour lequel de ses enfants) ;
/// - `features/learner/screens/demande_cours_screen.dart` (l'étudiant/
///   particulier fait la demande pour lui-même, `students` ne contient
///   alors qu'une seule entrée et le sélecteur est masqué).
class DemandeCoursForm extends ConsumerStatefulWidget {
  const DemandeCoursForm({
    super.key,
    required this.students,
    this.preselectedStudentId,
    this.onSuccess,
  });

  final List<StudentModel> students;
  final String? preselectedStudentId;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<DemandeCoursForm> createState() => _DemandeCoursFormState();
}

class _DemandeCoursFormState extends ConsumerState<DemandeCoursForm> {
  final _formKey = GlobalKey<FormState>();
  final _matiereController = TextEditingController();
  final _notesController = TextEditingController();

  String? _studentId;
  ModePref _modePref = ModePref.domicile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _studentId = widget.preselectedStudentId ??
        (widget.students.isNotEmpty ? widget.students.first.id : null);
  }

  @override
  void dispose() {
    _matiereController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_studentId == null) {
      setState(() => _errorMessage = 'Sélectionnez un élève.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(demandeRepositoryProvider).create(
            studentId: _studentId!,
            matiere: _matiereController.text.trim(),
            modePref: _modePref,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      ref.invalidate(demandesMineProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande envoyée avec succès !')),
      );
      _matiereController.clear();
      _notesController.clear();
      widget.onSuccess?.call();
    } catch (e) {
      setState(() => _errorMessage = 'Impossible d\'envoyer la demande. Réessayez.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            InlineErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          if (widget.students.length > 1) ...[
            DropdownButtonFormField<String>(
              initialValue: _studentId,
              decoration: const InputDecoration(labelText: 'Élève concerné'),
              items: widget.students
                  .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nomComplet)))
                  .toList(),
              onChanged: (v) => setState(() => _studentId = v),
            ),
            const SizedBox(height: 16),
          ],
          AppTextField(
            label: 'Matière',
            controller: _matiereController,
            hint: 'Ex: Mathématiques, Physique-Chimie...',
            prefixIcon: Icons.menu_book_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Matière requise';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ModePref>(
            initialValue: _modePref,
            decoration: const InputDecoration(labelText: 'Mode de cours préféré'),
            items: ModePref.values
                .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                .toList(),
            onChanged: (v) => setState(() => _modePref = v ?? _modePref),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Notes (optionnel)',
            controller: _notesController,
            maxLines: 3,
            hint: 'Précisions utiles pour le professeur...',
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Envoyer la demande',
            isLoading: _isLoading,
            onPressed: widget.students.isEmpty ? null : _submit,
          ),
          if (widget.students.isEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "Ajoutez d'abord un élève avant de faire une demande de cours.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
