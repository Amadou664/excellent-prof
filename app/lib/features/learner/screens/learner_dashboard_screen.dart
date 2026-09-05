import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../providers/auth_providers.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/notification_bell_button.dart';
import '../../../widgets/profile_summary_tab.dart';
import '../../parent/widgets/demandes_list_view.dart';
import 'mon_cahier_texte_screen.dart';

/// Dashboard de l'espace Étudiant/Particulier : mêmes fonctionnalités que
/// l'espace Parent, mais pour soi-même (pas de gestion d'enfants).
class LearnerDashboardScreen extends ConsumerStatefulWidget {
  const LearnerDashboardScreen({super.key});

  @override
  ConsumerState<LearnerDashboardScreen> createState() => _LearnerDashboardScreenState();
}

class _LearnerDashboardScreenState extends ConsumerState<LearnerDashboardScreen> {
  int _index = 0;

  static const _titles = ['Mon cahier de texte', 'Mes demandes', 'Mon profil'];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: const [NotificationBellButton()],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          const MonCahierTexteScreen(),
          const DemandesListView(),
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
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.learnerDemandeCours),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle demande'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Cahier'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Demandes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
