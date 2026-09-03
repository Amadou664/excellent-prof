import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/firebase_providers.dart';
import 'admin_dashboard_stats.dart';
import 'attribution_demandes.dart';
import 'gestion_annonces.dart';
import 'gestion_cours_pour_tous.dart';
import 'gestion_utilisateurs.dart';
import 'moderation_avis.dart';
import 'validation_enseignants.dart';

class _AdminSection {
  final String title;
  final IconData icon;
  final Widget screen;
  const _AdminSection(this.title, this.icon, this.screen);
}

/// Coquille de l'espace Admin : navigation par tiroir (Drawer) entre les 7
/// sections (stats, utilisateurs, candidatures, demandes, annonces, cours
/// pour tous, avis).
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _index = 0;

  static const _sections = [
    _AdminSection('Statistiques', Icons.dashboard_outlined, AdminDashboardStats()),
    _AdminSection('Utilisateurs', Icons.people_outline, GestionUtilisateurs()),
    _AdminSection('Candidatures profs', Icons.workspace_premium_outlined, ValidationEnseignants()),
    _AdminSection('Demandes de cours', Icons.assignment_outlined, AttributionDemandes()),
    _AdminSection('Annonces', Icons.campaign_outlined, GestionAnnonces()),
    _AdminSection('Cours pour tous', Icons.diversity_3_outlined, GestionCoursPourTous()),
    _AdminSection('Modération avis', Icons.reviews_outlined, ModerationAvis()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_sections[_index].title)),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: AppColors.primaryDarkGreen,
                child: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: AppColors.gold, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Administration',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < _sections.length; i++)
                      ListTile(
                        leading: Icon(_sections[i].icon),
                        title: Text(_sections[i].title),
                        selected: i == _index,
                        selectedColor: AppColors.primaryGreen,
                        onTap: () {
                          setState(() => _index = i);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
                onTap: () => ref.read(authServiceProvider).signOut(),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: _sections.map((s) => s.screen).toList(),
      ),
    );
  }
}
