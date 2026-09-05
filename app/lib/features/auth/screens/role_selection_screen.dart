import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../providers/auth_providers.dart';

/// Premier écran vu par un visiteur non connecté : choix du parcours
/// d'inscription parmi les 4 formulaires, ou accès à la connexion / aux
/// contenus publics (annonces, cours pour tous).
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  void _selectRole(WidgetRef ref, BuildContext context, Role role, String route) {
    ref.read(pendingRegistrationRoleProvider.notifier).state = role;
    context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 4),
              const Text(
                'Cours particuliers au Mali',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.paleGold, fontSize: 14),
              ),
              const SizedBox(height: 36),
              const Text(
                'Je souhaite créer un compte en tant que...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.family_restroom,
                title: "Je suis parent d'élève",
                subtitle: 'Suivez la scolarité de vos enfants',
                onTap: () => _selectRole(
                  ref,
                  context,
                  Role.parent,
                  AppRoutes.registerParent,
                ),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.workspace_premium,
                title: 'Je suis professeur',
                subtitle: 'Rejoignez notre réseau d\'enseignants',
                onTap: () => _selectRole(
                  ref,
                  context,
                  Role.professeur,
                  AppRoutes.registerTeacher,
                ),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.school_outlined,
                title: 'Je suis étudiant',
                subtitle: 'Trouvez un prof pour progresser',
                onTap: () => _selectRole(
                  ref,
                  context,
                  Role.etudiant,
                  AppRoutes.registerStudent,
                ),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.person_outline,
                title: 'Je suis particulier',
                subtitle: 'Apprenant autonome, à votre rythme',
                onTap: () => _selectRole(
                  ref,
                  context,
                  Role.particulier,
                  AppRoutes.registerParticulier,
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.login),
                  child: const Text(
                    "J'ai déjà un compte — Se connecter",
                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: [
                  TextButton(
                    onPressed: () => context.push(AppRoutes.annonces),
                    child: const Text('Annonces', style: TextStyle(color: Colors.white70)),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.coursPourTous),
                    child: const Text('Cours pour tous', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.paleGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryDarkGreen),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
