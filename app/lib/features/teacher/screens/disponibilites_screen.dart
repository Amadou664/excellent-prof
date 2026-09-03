import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/teachers_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/inline_error_banner.dart';
import '../../../widgets/loading_indicator.dart';

const _jours = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

/// Gestion des disponibilités du professeur. `PATCH /teachers/me` body
/// `{ disponibilites?, zoneGeo? }`.
///
/// `disponibilites` a la forme `{ "lundi": ["18:00-20:00"], "...": [] }` —
/// on saisit ici, pour chaque jour, une liste de créneaux séparés par des
/// virgules (ex: "08:00-10:00, 18:00-20:00").
class DisponibilitesScreen extends ConsumerStatefulWidget {
  const DisponibilitesScreen({super.key});

  @override
  ConsumerState<DisponibilitesScreen> createState() => _DisponibilitesScreenState();
}

class _DisponibilitesScreenState extends ConsumerState<DisponibilitesScreen> {
  final Map<String, TextEditingController> _controllers = {
    for (final jour in _jours) jour: TextEditingController(),
  };
  final _zoneGeoController = TextEditingController();

  bool _isSaving = false;
  bool _prefilled = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _zoneGeoController.dispose();
    super.dispose();
  }

  void _prefill(Map<String, List<String>> disponibilites, String zoneGeo) {
    if (_prefilled) return;
    for (final jour in _jours) {
      _controllers[jour]!.text = (disponibilites[jour] ?? []).join(', ');
    }
    _zoneGeoController.text = zoneGeo;
    _prefilled = true;
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final disponibilites = <String, List<String>>{
      for (final jour in _jours)
        jour: _controllers[jour]!
            .text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
    };
    try {
      await ref.read(teacherRepositoryProvider).updateMe(
            disponibilites: disponibilites,
            zoneGeo: _zoneGeoController.text.trim(),
          );
      ref.invalidate(teacherMeProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponibilités mises à jour.')),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Impossible de mettre à jour vos disponibilités.');
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
        _prefill(teacher.disponibilites, teacher.zoneGeo);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                InlineErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              AppTextField(
                label: 'Zone géographique',
                controller: _zoneGeoController,
                prefixIcon: Icons.map_outlined,
                hint: 'Ex: Bamako - Rive Gauche',
              ),
              const SizedBox(height: 20),
              const Text(
                'Créneaux disponibles par jour',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Séparez plusieurs créneaux par des virgules, ex: "08:00-10:00, 18:00-20:00".',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ..._jours.map(
                (jour) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppTextField(
                    label: jour[0].toUpperCase() + jour.substring(1),
                    controller: _controllers[jour],
                    hint: 'Ex: 18:00-20:00',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(label: 'Enregistrer', isLoading: _isSaving, onPressed: _submit),
            ],
          ),
        );
      },
    );
  }
}
