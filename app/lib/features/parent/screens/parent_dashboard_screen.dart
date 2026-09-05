import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../providers/auth_providers.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/notification_bell_button.dart';
import '../../../widgets/profile_summary_tab.dart';
import '../widgets/demandes_list_view.dart';
import 'mes_enfants_screen.dart';

/// Dashboard de l'espace Parent : navigation par onglets entre "Mes
/// enfants", "Mes demandes" et "Profil".
class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  int _index = 0;

  static const _titles = ['Mes enfants', 'Mes demandes', 'Mon profil'];

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
          const MesEnfantsScreen(),
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
      floatingActionButton: _fab(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Enfants'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Demandes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget? _fab(BuildContext context) {
    if (_index == 0) {
      return FloatingActionButton(
        onPressed: () => context.push(AppRoutes.parentAjouterEnfant),
        tooltip: 'Ajouter un enfant',
        child: const Icon(Icons.add),
      );
    }
    if (_index == 1) {
      return FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.parentDemandeCours),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle demande'),
      );
    }
    return null;
  }
}
