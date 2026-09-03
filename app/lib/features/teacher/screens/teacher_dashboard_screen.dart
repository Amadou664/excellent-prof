import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/profile_summary_tab.dart';
import 'disponibilites_screen.dart';
import 'mes_eleves_screen.dart';
import 'profil_candidature_screen.dart';

/// Dashboard de l'espace Professeur : navigation par onglets entre "Mes
/// élèves", "Disponibilités", "Candidature" et "Profil".
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> {
  int _index = 0;

  static const _titles = ['Mes élèves', 'Disponibilités', 'Candidature', 'Mon profil'];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: [
          const MesElevesScreen(),
          const DisponibilitesScreen(),
          const ProfilCandidatureScreen(),
          userAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorState(
              error: e,
              onRetry: () => ref.invalidate(currentUserProvider),
            ),
            data: (user) => user == null
                ? const LoadingIndicator()
                : ProfileSummaryTab(user: user),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Élèves'),
          BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), label: 'Dispos'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium_outlined), label: 'Candidature'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
