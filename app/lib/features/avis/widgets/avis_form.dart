import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/avis_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/inline_error_banner.dart';

/// Formulaire pour laisser un avis (note 1-5 + commentaire) sur un
/// professeur. `POST /avis` body `{ professeurId, note, commentaire }`.
///
/// Utilisé typiquement dans une bottom sheet / dialog ouverte depuis une
/// demande de cours `TERMINEE`.
class AvisForm extends ConsumerStatefulWidget {
  const AvisForm({super.key, required this.professeurId, this.onSubmitted});

  final String professeurId;
  final VoidCallback? onSubmitted;

  @override
  ConsumerState<AvisForm> createState() => _AvisFormState();
}

class _AvisFormState extends ConsumerState<AvisForm> {
  final _commentaireController = TextEditingController();
  int _note = 5;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_commentaireController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ajoutez un commentaire.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(avisRepositoryProvider).create(
            professeurId: widget.professeurId,
            note: _note,
            commentaire: _commentaireController.text.trim(),
          );
      ref.invalidate(avisByProfesseurProvider(widget.professeurId));
      if (!mounted) return;
      widget.onSubmitted?.call();
    } catch (e) {
      setState(() => _errorMessage = "Impossible d'envoyer votre avis. Réessayez.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Laisser un avis sur ce professeur',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (_errorMessage != null) ...[
          InlineErrorBanner(message: _errorMessage!),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            return IconButton(
              onPressed: () => setState(() => _note = starIndex),
              icon: Icon(
                starIndex <= _note ? Icons.star : Icons.star_border,
                color: AppColors.gold,
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentaireController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Votre commentaire',
            hintText: 'Décrivez votre expérience avec ce professeur...',
          ),
        ),
        const SizedBox(height: 16),
        AppButton(label: 'Envoyer mon avis', isLoading: _isLoading, onPressed: _submit),
      ],
    );
  }
}
