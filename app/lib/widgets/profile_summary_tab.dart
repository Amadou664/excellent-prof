import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import '../providers/repository_providers.dart';
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
          onPressed: () => ref.read(authServiceProvider).signOut(),
          icon: const Icon(Icons.logout, color: AppColors.error),
          label: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
        ),
      ],
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
