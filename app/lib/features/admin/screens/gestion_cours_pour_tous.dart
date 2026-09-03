import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/cours_pour_tous_model.dart';
import '../../../providers/cours_pour_tous_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/inline_error_banner.dart';
import '../../../widgets/loading_indicator.dart';

/// Gestion (CRUD) des campagnes "cours pour tous" (ADMIN).
/// `POST/PATCH/DELETE /cours-pour-tous`.
class GestionCoursPourTous extends ConsumerWidget {
  const GestionCoursPourTous({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursAsync = ref.watch(coursPourTousProvider);

    return Scaffold(
      body: coursAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(coursPourTousProvider)),
        data: (cours) {
          if (cours.isEmpty) {
            return const EmptyState(message: 'Aucune campagne créée.', icon: Icons.diversity_3_outlined);
          }
          final sorted = [...cours]..sort((a, b) => a.dateDebut.compareTo(b.dateDebut));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = sorted[index];
              return Card(
                child: ListTile(
                  title: Text(c.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${c.matiere} • ${c.tarif} FCFA\n'
                    'Du ${DateFormat('dd/MM/yyyy').format(c.dateDebut)} au ${DateFormat('dd/MM/yyyy').format(c.dateFin)}\n'
                    '${c.placesRestantes}/${c.placesDisponibles} places restantes',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _openForm(context, ref, cours: c);
                      if (v == 'delete') _delete(context, ref, c);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, CoursPourTousModel c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette campagne ?'),
        content: Text(c.titre),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(coursPourTousRepositoryProvider).delete(c.id);
      ref.invalidate(coursPourTousProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suppression impossible.')));
      }
    }
  }

  void _openForm(BuildContext context, WidgetRef ref, {CoursPourTousModel? cours}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _CoursFormSheet(cours: cours),
      ),
    );
  }
}

class _CoursFormSheet extends ConsumerStatefulWidget {
  const _CoursFormSheet({this.cours});

  final CoursPourTousModel? cours;

  @override
  ConsumerState<_CoursFormSheet> createState() => _CoursFormSheetState();
}

class _CoursFormSheetState extends ConsumerState<_CoursFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _matiereController;
  late final TextEditingController _tarifController;
  late final TextEditingController _placesController;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final c = widget.cours;
    _titreController = TextEditingController(text: c?.titre ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _matiereController = TextEditingController(text: c?.matiere ?? '');
    _tarifController = TextEditingController(text: c?.tarif.toString() ?? '');
    _placesController = TextEditingController(text: c?.placesDisponibles.toString() ?? '');
    _dateDebut = c?.dateDebut;
    _dateFin = c?.dateFin;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _matiereController.dispose();
    _tarifController.dispose();
    _placesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDebut}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isDebut) {
        _dateDebut = picked;
      } else {
        _dateFin = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateDebut == null || _dateFin == null) {
      setState(() => _errorMessage = 'Sélectionnez les dates de début et de fin.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(coursPourTousRepositoryProvider);
      final tarif = num.tryParse(_tarifController.text.trim()) ?? 0;
      final places = int.tryParse(_placesController.text.trim()) ?? 0;
      if (widget.cours == null) {
        await repo.create(
          titre: _titreController.text.trim(),
          description: _descriptionController.text.trim(),
          matiere: _matiereController.text.trim(),
          dateDebut: _dateDebut!,
          dateFin: _dateFin!,
          tarif: tarif,
          placesDisponibles: places,
        );
      } else {
        await repo.update(
          id: widget.cours!.id,
          titre: _titreController.text.trim(),
          description: _descriptionController.text.trim(),
          matiere: _matiereController.text.trim(),
          dateDebut: _dateDebut!,
          dateFin: _dateFin!,
          tarif: tarif,
          placesDisponibles: places,
        );
      }
      ref.invalidate(coursPourTousProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = "Impossible d'enregistrer la campagne.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final debutLabel = _dateDebut == null ? 'Date de début' : DateFormat('dd/MM/yyyy').format(_dateDebut!);
    final finLabel = _dateFin == null ? 'Date de fin' : DateFormat('dd/MM/yyyy').format(_dateFin!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.cours == null ? 'Nouvelle campagne' : 'Modifier la campagne',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              InlineErrorBanner(message: _errorMessage!),
              const SizedBox(height: 16),
            ],
            AppTextField(
              label: 'Titre',
              controller: _titreController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 3,
              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Matière',
              controller: _matiereController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => _pickDate(isDebut: true), child: Text(debutLabel)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(onPressed: () => _pickDate(isDebut: false), child: Text(finLabel)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Tarif (FCFA)',
                    controller: _tarifController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Places disponibles',
                    controller: _placesController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Enregistrer', isLoading: _isSaving, onPressed: _submit),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
