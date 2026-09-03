import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../providers/firebase_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/inline_error_banner.dart';
import '../register_helper.dart';

/// Formulaire d'inscription "Je suis professeur".
///
/// En plus des infos communes, collecte `specialites`, `bio` et
/// `diplomesUrls` (upload Firebase Storage -> URLs) pour construire le
/// `teacherProfile` attendu par `POST /auth/register`. Le compte créé aura
/// `statutCandidature = SOUMISE` et `User.status = EN_ATTENTE` côté backend
/// : l'utilisateur sera redirigé vers l'écran "Candidature en attente"
/// (voir router) tant qu'un admin ne l'aura pas validé.
class RegisterTeacherScreen extends ConsumerStatefulWidget {
  const RegisterTeacherScreen({super.key});

  @override
  ConsumerState<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends ConsumerState<RegisterTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _villeController = TextEditingController();
  final _bioController = TextEditingController();
  final _specialiteInputController = TextEditingController();

  final List<String> _specialites = [];
  final List<_UploadedDiplome> _diplomes = [];

  bool _isLoading = false;
  bool _isUploading = false;
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
    _bioController.dispose();
    _specialiteInputController.dispose();
    super.dispose();
  }

  void _addSpecialite() {
    final value = _specialiteInputController.text.trim();
    if (value.isEmpty) return;
    if (!_specialites.contains(value)) {
      setState(() => _specialites.add(value));
    }
    _specialiteInputController.clear();
  }

  Future<void> _pickAndUploadDiplome() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      // On utilise un identifiant temporaire tant que le compte Firebase
      // n'existe pas encore : le nom du fichier suffit à éviter les
      // collisions au sein de cette session d'inscription.
      final tempUid = DateTime.now().millisecondsSinceEpoch.toString();
      final storage = ref.read(storageServiceProvider);
      final url = await storage.uploadDiplome(
        uid: tempUid,
        file: File(file.path),
        fileName: file.name,
      );
      setState(() => _diplomes.add(_UploadedDiplome(name: file.name, url: url)));
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Échec de l'envoi du document. Réessayez.");
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_specialites.isEmpty) {
      setState(() => _errorMessage = 'Ajoutez au moins une spécialité.');
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
      role: Role.professeur,
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      ville: _villeController.text.trim(),
      teacherProfile: {
        'specialites': _specialites,
        'bio': _bioController.text.trim(),
        'diplomesUrls': _diplomes.map((d) => d.url).toList(),
      },
      onError: (message) {
        if (mounted) setState(() => _errorMessage = message);
      },
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription — Professeur')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Rejoignez notre réseau d'enseignants. Votre candidature "
                  "sera examinée par notre équipe (entretien) avant validation.",
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
                const SizedBox(height: 20),
                const Text('Spécialités enseignées', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Ex: Mathématiques',
                        controller: _specialiteInputController,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addSpecialite,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (_specialites.isNotEmpty) ...[
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
                ],
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Présentation / bio',
                  controller: _bioController,
                  maxLines: 4,
                  hint: 'Votre parcours, votre pédagogie, votre expérience...',
                  validator: _req,
                ),
                const SizedBox(height: 20),
                const Text('Diplômes / certificats', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  "Ajoutez une photo de vos diplômes (facultatif à ce stade, "
                  "pourra être complété plus tard).",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ..._diplomes.map(
                  (d) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined, color: AppColors.primaryGreen),
                    title: Text(d.name, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _diplomes.remove(d)),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickAndUploadDiplome,
                  icon: _isUploading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isUploading ? 'Envoi en cours...' : 'Ajouter un document'),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Envoyer ma candidature',
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

class _UploadedDiplome {
  final String name;
  final String url;
  const _UploadedDiplome({required this.name, required this.url});
}
