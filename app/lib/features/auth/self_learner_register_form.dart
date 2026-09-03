import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/enums.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/inline_error_banner.dart';
import 'register_helper.dart';

/// Formulaire d'inscription partagé par "Je suis étudiant" et "Je suis
/// particulier" (`register_student_screen.dart` / `register_particulier_screen.dart`) :
/// les deux rôles créent un `Student` "autonome" (`studentSelf`, sans
/// `parentId`) en plus de leur `User`, seul le `role` transmis diffère.
///
/// Voir API_CONTRACT.md : `studentSelf: { niveau, programme, dateNaissance }`.
class SelfLearnerRegisterForm extends ConsumerStatefulWidget {
  const SelfLearnerRegisterForm({
    super.key,
    required this.role,
    required this.title,
    required this.description,
  });

  final Role role;
  final String title;
  final String description;

  @override
  ConsumerState<SelfLearnerRegisterForm> createState() => _SelfLearnerRegisterFormState();
}

class _SelfLearnerRegisterFormState extends ConsumerState<SelfLearnerRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _villeController = TextEditingController();

  Niveau _niveau = Niveau.college;
  Programme _programme = Programme.malien;
  DateTime? _dateNaissance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateNaissance() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 15),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Date de naissance',
    );
    if (picked != null) setState(() => _dateNaissance = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateNaissance == null) {
      setState(() => _errorMessage = 'Sélectionnez votre date de naissance.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await runRegistrationFlow(
      ref: ref,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: widget.role,
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      ville: _villeController.text.trim(),
      studentSelf: {
        'niveau': _niveau.apiValue,
        'programme': _programme.apiValue,
        'dateNaissance': _dateNaissance!.toIso8601String(),
      },
      onError: (message) {
        if (mounted) setState(() => _errorMessage = message);
      },
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateNaissance == null
        ? 'Sélectionner une date'
        : DateFormat('dd/MM/yyyy').format(_dateNaissance!);

    return Scaffold(
      appBar: AppBar(title: Text('Inscription — ${widget.title}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.description, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                if (_errorMessage != null) ...[
                  InlineErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Prénom',
                        controller: _prenomController,
                        validator: _req,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Nom',
                        controller: _nomController,
                        validator: _req,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Téléphone',
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: _req,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Ville',
                  controller: _villeController,
                  prefixIcon: Icons.location_city_outlined,
                  validator: _req,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDateNaissance,
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
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Mot de passe',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return '6 caractères minimum';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Créer mon compte',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _req(String? v) {
  if (v == null || v.trim().isEmpty) return 'Champ requis';
  return null;
}
