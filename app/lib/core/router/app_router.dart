import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/annonces/screens/annonce_detail_screen.dart';
import '../../features/annonces/screens/annonces_list_screen.dart';
import '../../features/auth/screens/connection_error_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/pending_validation_screen.dart';
import '../../features/auth/screens/register_particulier_screen.dart';
import '../../features/auth/screens/register_parent_screen.dart';
import '../../features/auth/screens/register_student_screen.dart';
import '../../features/auth/screens/register_teacher_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/cours_pour_tous/screens/cours_detail_screen.dart';
import '../../features/cours_pour_tous/screens/cours_list_screen.dart';
import '../../features/cours_pour_tous/screens/inscription_screen.dart';
import '../../features/learner/screens/demande_cours_screen.dart';
import '../../features/learner/screens/learner_dashboard_screen.dart';
import '../../features/parent/screens/ajouter_enfant_screen.dart';
import '../../features/parent/screens/cahier_texte_view_screen.dart';
import '../../features/parent/screens/demande_cours_screen.dart';
import '../../features/parent/screens/parent_dashboard_screen.dart';
import '../../features/teacher/screens/cahier_texte_edit_screen.dart';
import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../models/enums.dart';
import '../../providers/auth_providers.dart';
import 'app_routes.dart';

/// Écrans d'auth pour lesquels un utilisateur Firebase connecté mais sans
/// profil backend encore créé (ou pas encore redirigé) peut naviguer
/// librement (ex: revenir en arrière pour choisir un autre rôle, se
/// connecter avec un autre compte...).
const _authFlowRoutes = {
  AppRoutes.roleSelection,
  AppRoutes.login,
  AppRoutes.registerParent,
  AppRoutes.registerTeacher,
  AppRoutes.registerStudent,
  AppRoutes.registerParticulier,
};

bool _isAlwaysPublic(String loc) =>
    loc.startsWith(AppRoutes.annonces) || loc.startsWith(AppRoutes.coursPourTous);

String _registerRouteForRole(Role role) {
  switch (role) {
    case Role.parent:
      return AppRoutes.registerParent;
    case Role.professeur:
      return AppRoutes.registerTeacher;
    case Role.etudiant:
      return AppRoutes.registerStudent;
    case Role.particulier:
      return AppRoutes.registerParticulier;
    case Role.admin:
      return AppRoutes.roleSelection;
  }
}

String _dashboardForRole(Role role) {
  switch (role) {
    case Role.parent:
      return AppRoutes.parentDashboard;
    case Role.professeur:
      return AppRoutes.teacherDashboard;
    case Role.etudiant:
    case Role.particulier:
      return AppRoutes.learnerDashboard;
    case Role.admin:
      return AppRoutes.adminDashboard;
  }
}

bool _isAllowedForRole(String loc, Role role) {
  if (loc.startsWith(AppRoutes.parentDashboard)) return role == Role.parent;
  if (loc.startsWith(AppRoutes.teacherDashboard)) return role == Role.professeur;
  if (loc.startsWith(AppRoutes.learnerDashboard)) {
    return role == Role.etudiant || role == Role.particulier;
  }
  if (loc.startsWith(AppRoutes.adminDashboard)) return role == Role.admin;
  return true;
}

/// Petit `ChangeNotifier` utilisé uniquement pour relayer à `go_router`
/// (`refreshListenable`) les changements de `authStateProvider` /
/// `currentUserProvider`, sans jamais recréer l'objet `GoRouter` lui-même
/// (voir `_routerRefreshProvider` ci-dessous).
class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final _routerRefreshProvider = Provider<_RouterRefreshNotifier>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen(authStateProvider, (_, _) => notifier.refresh());
  ref.listen(currentUserProvider, (_, _) => notifier.refresh());
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Router unique de l'application. La logique de redirection (voir
/// `_redirect`) implémente exactement le flux demandé par la spec produit :
/// non connecté -> sélection de profil/login ; connecté mais profil pas
/// encore créé côté backend -> formulaire d'inscription du rôle choisi ;
/// PROFESSEUR en `EN_ATTENTE` -> écran de candidature en attente ; sinon ->
/// dashboard du rôle.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Center(
        child: Text('Aucune route ne correspond à "${state.uri}".'),
      ),
    ),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.registerParent,
        builder: (context, state) => const RegisterParentScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerTeacher,
        builder: (context, state) => const RegisterTeacherScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerStudent,
        builder: (context, state) => const RegisterStudentScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerParticulier,
        builder: (context, state) => const RegisterParticulierScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingValidation,
        builder: (context, state) => const PendingValidationScreen(),
      ),
      GoRoute(
        path: AppRoutes.connectionError,
        builder: (context, state) => const ConnectionErrorScreen(),
      ),

      // --- Parent ---
      GoRoute(
        path: AppRoutes.parentDashboard,
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentAjouterEnfant,
        builder: (context, state) => const AjouterEnfantScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentCahierTexte,
        builder: (context, state) => CahierTexteViewScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.parentDemandeCours,
        builder: (context, state) => DemandeCoursScreen(
          preselectedStudentId: state.uri.queryParameters['studentId'],
        ),
      ),

      // --- Professeur ---
      GoRoute(
        path: AppRoutes.teacherDashboard,
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherCahierTexteEdit,
        builder: (context, state) => CahierTexteEditScreen(
          seanceId: state.pathParameters['seanceId']!,
        ),
      ),

      // --- Étudiant / particulier ---
      GoRoute(
        path: AppRoutes.learnerDashboard,
        builder: (context, state) => const LearnerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.learnerDemandeCours,
        builder: (context, state) => const LearnerDemandeCoursScreen(),
      ),

      // --- Admin ---
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // --- Annonces ---
      GoRoute(
        path: AppRoutes.annonces,
        builder: (context, state) => const AnnoncesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.annonceDetail,
        builder: (context, state) => AnnonceDetailScreen(id: state.pathParameters['id']!),
      ),

      // --- Messagerie ---
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => ChatScreen(
          demandeId: state.pathParameters['demandeId']!,
        ),
      ),

      // --- Cours pour tous ---
      GoRoute(
        path: AppRoutes.coursPourTous,
        builder: (context, state) => const CoursListScreen(),
      ),
      GoRoute(
        path: AppRoutes.coursPourTousDetail,
        builder: (context, state) => CoursDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.coursPourTousInscription,
        builder: (context, state) => InscriptionScreen(coursId: state.pathParameters['id']!),
      ),
    ],
  );
});

String? _redirect(Ref ref, GoRouterState state) {
  final loc = state.matchedLocation;

  final authAsync = ref.read(authStateProvider);
  if (authAsync.isLoading && !authAsync.hasValue) {
    return loc == AppRoutes.splash ? null : AppRoutes.splash;
  }
  if (authAsync.hasError) {
    return loc == AppRoutes.roleSelection ? null : AppRoutes.roleSelection;
  }

  final firebaseUser = authAsync.value;
  if (firebaseUser == null) {
    if (_isAlwaysPublic(loc) || _authFlowRoutes.contains(loc)) return null;
    return AppRoutes.roleSelection;
  }

  final userAsync = ref.read(currentUserProvider);
  if (userAsync.isLoading && !userAsync.hasValue) {
    return loc == AppRoutes.splash ? null : AppRoutes.splash;
  }
  if (userAsync.hasError) {
    // Backend injoignable pour une raison autre qu'un profil manquant (404,
    // déjà géré par `currentUserProvider` en renvoyant `null` dans ce cas).
    if (_isAlwaysPublic(loc)) return null;
    return loc == AppRoutes.connectionError ? null : AppRoutes.connectionError;
  }

  final backendUser = userAsync.value;

  if (backendUser == null) {
    // Compte Firebase créé mais profil backend pas encore créé.
    final pendingRole = ref.read(pendingRegistrationRoleProvider);
    final target = pendingRole != null
        ? _registerRouteForRole(pendingRole)
        : AppRoutes.roleSelection;
    if (_authFlowRoutes.contains(loc)) return null;
    return loc == target ? null : target;
  }

  if (backendUser.role == Role.professeur && backendUser.status == UserStatus.enAttente) {
    if (_isAlwaysPublic(loc) || loc == AppRoutes.pendingValidation) return null;
    return AppRoutes.pendingValidation;
  }

  // Profil complet et actif : plus besoin des écrans d'auth/splash/attente.
  if (_authFlowRoutes.contains(loc) ||
      loc == AppRoutes.splash ||
      loc == AppRoutes.pendingValidation ||
      loc == AppRoutes.connectionError) {
    return _dashboardForRole(backendUser.role);
  }

  if (!_isAlwaysPublic(loc) && !_isAllowedForRole(loc, backendUser.role)) {
    return _dashboardForRole(backendUser.role);
  }

  return null;
}
