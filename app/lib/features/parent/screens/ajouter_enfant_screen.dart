import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/enums.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/students_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/inline_error_banner.dart';

/// Formulaire d'ajout d'un enfant, `POST /students` body
/// `{ nom, prenom, dateNaissance, niveau, programme }` (PARENT).
class AjouterEnfantScreen extends ConsumerStatefulWidget {
  const AjouterEnfantScreen({super.key});

  @override
  ConsumerState<AjouterEnfantScreen> createState() => _AjouterEnfantScreenState();
}

class _AjouterEnfantScreenState extends ConsumerState<AjouterEnfantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  Niveau _niveau = Niveau.fondamental;
  Programme _programme = Programme.malien;
  DateTime? _dateNaissance;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 10),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
      helpText: 'Date de naissance',
    );
    if (picked != null) setState(() => _dateNaissance = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateNaissance == null) {
      setState(() => _errorMessage = 'Sélectionnez la date de naissance.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(studentRepositoryProvider).create(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            dateNaissance: _dateNaissance!,
            niveau: _niveau,
            programme: _programme,
          );
      ref.invalidate(studentsMineProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorMessage = "Impossible d'ajouter cet élève. Réessayez.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateNaissance == null
        ? 'Sélectionner une date'
        : DateFormat('dd/MM/yyyy').format(_dateNaissance!);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un enfant')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  InlineErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  label: 'Prénom',
                  controller: _prenomController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nom',
                  controller: _nomController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(dateLabel),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Niveau>(
                  initialValue: _niveau,
                  decoration: const InputDecoration(labelText: 'Niveau scolaire'),
                  items: Niveau.values
                      .map((n) => DropdownMenuItem(value: n, child: Text(n.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _niveau = v ?? _niveau),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Programme>(
                  initialValue: _programme,
                  decoration: const InputDecoration(labelText: 'Programme'),
                  items: Programme.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _programme = v ?? _programme),
                ),
                const SizedBox(height: 24),
                AppButton(label: 'Ajouter', isLoading: _isLoading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
