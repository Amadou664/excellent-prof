import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/enums.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/inline_error_banner.dart';
import '../register_helper.dart';

/// Formulaire d'inscription "Je suis parent d'élève".
///
/// Crée le compte Firebase Auth puis appelle `POST /auth/register` avec
/// `role: PARENT` (pas de `teacherProfile` ni `studentSelf` — les enfants
/// seront ajoutés ensuite depuis l'espace Parent via `POST /students`).
class RegisterParentScreen extends ConsumerStatefulWidget {
  const RegisterParentScreen({super.key});

  @override
  ConsumerState<RegisterParentScreen> createState() => _RegisterParentScreenState();
}

class _RegisterParentScreenState extends ConsumerState<RegisterParentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _villeController = TextEditingController();

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await runRegistrationFlow(
      ref: ref,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: Role.parent,
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      ville: _villeController.text.trim(),
      onError: (message) {
        if (mounted) setState(() => _errorMessage = message);
      },
    );
    // En cas de succès, le router redirige automatiquement vers le dashboard
    // parent (currentUserProvider a été invalidé par runRegistrationFlow).

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription — Parent d'élève")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Créez votre compte pour suivre la scolarité de vos enfants '
                  'et réserver des cours particuliers.',
                  style: TextStyle(color: Colors.grey),
                ),
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
                        validator: _requiredValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Nom',
                        controller: _nomController,
                        validator: _requiredValidator,
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
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Ville',
                  controller: _villeController,
                  prefixIcon: Icons.location_city_outlined,
                  validator: _requiredValidator,
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
                  label: "Créer mon compte",
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

String? _requiredValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Champ requis';
  return null;
}
