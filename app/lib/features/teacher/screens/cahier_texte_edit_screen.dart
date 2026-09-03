import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/cahier_texte_model.dart';
import '../../../models/enums.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/seances_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/inline_error_banner.dart';
import '../../../widgets/loading_indicator.dart';

/// Formulaire de remplissage du "Cahier de texte" à la fin d'une séance
/// (PROFESSEUR assigné). `PUT /seances/:id/cahier-texte` — upsert.
class CahierTexteEditScreen extends ConsumerStatefulWidget {
  const CahierTexteEditScreen({super.key, required this.seanceId});

  final String seanceId;

  @override
  ConsumerState<CahierTexteEditScreen> createState() => _CahierTexteEditScreenState();
}

class _CahierTexteEditScreenState extends ConsumerState<CahierTexteEditScreen> {
  final _contenuController = TextEditingController();
  final _exercicesController = TextEditingController();
  final _devoirsController = TextEditingController();
  final _observationsController = TextEditingController();

  bool _marquerEffectuee = true;
  bool _isSaving = false;
  bool _prefilled = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contenuController.dispose();
    _exercicesController.dispose();
    _devoirsController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  void _prefill(CahierTexteModel? cahier) {
    if (_prefilled || cahier == null) return;
    _contenuController.text = cahier.contenu;
    _exercicesController.text = cahier.exercices;
    _devoirsController.text = cahier.devoirs;
    _observationsController.text = cahier.observations;
    _prefilled = true;
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ref.read(seanceRepositoryProvider).upsertCahierTexte(
            seanceId: widget.seanceId,
            contenu: _contenuController.text.trim(),
            exercices: _exercicesController.text.trim(),
            devoirs: _devoirsController.text.trim(),
            observations: _observationsController.text.trim(),
          );
      if (_marquerEffectuee) {
        await ref.read(seanceRepositoryProvider).updateStatut(
              seanceId: widget.seanceId,
              statut: SeanceStatut.effectuee,
            );
      }
      ref.invalidate(cahierTexteProvider(widget.seanceId));
      ref.invalidate(seancesMineProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cahier de texte enregistré.')),
      );
      context.pop();
    } catch (e) {
      setState(() => _errorMessage = "Impossible d'enregistrer le cahier de texte.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cahierAsync = ref.watch(cahierTexteProvider(widget.seanceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Cahier de texte')),
      body: SafeArea(
        child: cahierAsync.when(
          loading: () => const LoadingIndicator(),
          error: (_, _) {
            // Si le cahier n'existe pas encore (première saisie), l'API peut
            // renvoyer une 404 : on traite ce cas comme "vide" plutôt qu'une
            // erreur bloquante.
            return _buildForm(context);
          },
          data: (cahier) {
            _prefill(cahier);
            return _buildForm(context);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            InlineErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          AppTextField(
            label: 'Contenu du cours',
            controller: _contenuController,
            maxLines: 4,
            hint: 'Ce qui a été enseigné pendant la séance...',
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Exercices réalisés',
            controller: _exercicesController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Devoirs à faire',
            controller: _devoirsController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Observations',
            controller: _observationsController,
            maxLines: 3,
            hint: "Comportement, progrès, points d'attention...",
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _marquerEffectuee,
            onChanged: (v) => setState(() => _marquerEffectuee = v),
            title: const Text('Marquer la séance comme effectuée'),
          ),
          const SizedBox(height: 12),
          AppButton(label: 'Enregistrer', isLoading: _isSaving, onPressed: _submit),
        ],
      ),
    );
  }
}
