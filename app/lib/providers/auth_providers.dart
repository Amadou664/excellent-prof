import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/enums.dart';
import '../models/user_model.dart';
import 'firebase_providers.dart';
import 'repository_providers.dart';

/// État de connexion Firebase brut (source de vérité n°1 pour le router).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Rôle choisi par l'utilisateur sur l'écran de sélection de profil, mémorisé
/// en mémoire (non persisté) pour pouvoir le renvoyer vers le bon formulaire
/// d'inscription si son profil backend n'existe pas encore (ex: compte
/// Firebase créé mais `POST /auth/register` pas encore terminé/réussi).
final pendingRegistrationRoleProvider = StateProvider<Role?>((ref) => null);

/// Profil applicatif (`GET /auth/me`) de l'utilisateur Firebase courant.
///
/// - `null` alors qu'aucun utilisateur Firebase n'est connecté -> non
///   authentifié.
/// - `null` alors qu'un utilisateur Firebase EST connecté -> compte Firebase
///   créé mais profil backend pas encore créé (404 `/auth/me`) : il faut
///   compléter l'inscription.
/// - non-null -> profil complet, utilisé par le router pour les
///   redirections de rôle/statut.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseUser = ref.watch(authStateProvider).valueOrNull;
  if (firebaseUser == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  try {
    return await repo.me();
  } on ApiException catch (e) {
    if (e.statusCode == 404) {
      return null;
    }
    rethrow;
  }
});
