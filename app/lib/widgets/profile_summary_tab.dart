import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import '../providers/repository_providers.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'inline_error_banner.dart';
import 'status_chip.dart';

/// Onglet "Profil" générique réutilisé par les dashboards Parent, Professeur
/// et Étudiant/Particulier : affiche les infos de base de l'utilisateur
/// connecté et un bouton de déconnexion. [extra] permet d'insérer du contenu
/// spécifique au rôle (ex: bouton de gestion de candidature).
class ProfileSummaryTab extends ConsumerStatefulWidget {
  const ProfileSummaryTab({super.key, required this.user, this.extra});

  final UserModel user;
  final List<Widget>? extra;

  @override
  ConsumerState<ProfileSummaryTab> createState() => _ProfileSummaryTabState();
}

class _ProfileSummaryTabState extends ConsumerState<ProfileSummaryTab> {
  bool _isUploadingPhoto = false;

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await ref.read(fileRepositoryProvider).upload(
            bytes: bytes,
            filename: file.name,
            mimeType: file.mimeType ?? 'image/jpeg',
          );
      await ref.read(userRepositoryProvider).updateMe(photoUrl: url);
      ref.invalidate(currentUserProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'envoi de la photo. Réessayez.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _openChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: const _ChangePasswordSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final extra = widget.extra;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.paleGold,
                backgroundImage: user.photoUrl != null
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, color: AppColors.primaryDarkGreen),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _isUploadingPhoto ? null : _changePhoto,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryDarkGreen,
                    child: _isUploadingPhoto
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.nomComplet,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: StatusChip.userStatus(user.status),
          ),
        ),
        const SizedBox(height: 24),
        _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
        _InfoTile(icon: Icons.phone_outlined, label: 'Téléphone', value: user.telephone),
        _InfoTile(icon: Icons.location_city_outlined, label: 'Ville', value: user.ville),
        _InfoTile(icon: Icons.badge_outlined, label: 'Rôle', value: user.role.label),
        if (extra != null) ...[
          const SizedBox(height: 12),
          ...extra,
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _openChangePassword,
          icon: const Icon(Icons.lock_reset_outlined),
          label: const Text('Changer le mot de passe'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ref.read(authServiceProvider).signOut(),
          icon: const Icon(Icons.logout, color: AppColors.error),
          label: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
        ),
      ],
    );
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authService = ref.read(authServiceProvider);
    try {
      await authService.reauthenticate(_currentController.text);
      await authService.updatePassword(_newController.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = authService.messageFromException(e));
    } catch (_) {
      setState(() => _errorMessage = 'Une erreur inattendue est survenue.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Changer le mot de passe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null) ...[
            InlineErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          AppTextField(
            label: 'Mot de passe actuel',
            controller: _currentController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Nouveau mot de passe',
            controller: _newController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            validator: (v) => v == null || v.length < 6 ? '6 caractères minimum' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Confirmer le nouveau mot de passe',
            controller: _confirmController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            validator: (v) =>
                v != _newController.text ? 'Les mots de passe ne correspondent pas' : null,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Valider',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
