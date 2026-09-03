import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/repository_providers.dart';

/// Logique partagée par les 4 écrans d'inscription : crée le compte Firebase
/// Auth (email/mot de passe) puis appelle `POST /auth/register` avec le rôle
/// et les infos de profil (voir API_CONTRACT.md).
///
/// Retourne le [UserModel] créé en cas de succès, ou `null` en cas d'échec
/// (le message d'erreur est alors transmis à [onError]).
Future<UserModel?> runRegistrationFlow({
  required WidgetRef ref,
  required String email,
  required String password,
  required Role role,
  required String nom,
  required String prenom,
  required String telephone,
  required String ville,
  Map<String, dynamic>? teacherProfile,
  Map<String, dynamic>? studentSelf,
  required void Function(String message) onError,
}) async {
  final authService = ref.read(authServiceProvider);
  final authRepo = ref.read(authRepositoryProvider);

  try {
    await authService.registerWithEmail(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      // Cas de reprise : le compte Firebase existe déjà, probablement suite
      // à une inscription précédente interrompue avant l'appel réussi à
      // `POST /auth/register` (ex: app fermée entre les deux étapes). On
      // tente de se reconnecter avec les mêmes identifiants pour reprendre
      // l'inscription là où elle s'est arrêtée, plutôt que de bloquer
      // l'utilisateur.
      try {
        await authService.signInWithEmail(email: email, password: password);
      } on FirebaseAuthException catch (_) {
        onError(
          'Un compte existe déjà avec cet email. Si c\'est le vôtre, '
          'utilisez "J\'ai déjà un compte" avec le bon mot de passe.',
        );
        return null;
      }
    } else {
      onError(authService.messageFromException(e));
      return null;
    }
  }

  try {
    final user = await authRepo.register(
      role: role,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      ville: ville,
      teacherProfile: teacherProfile,
      studentSelf: studentSelf,
    );
    ref.invalidate(currentUserProvider);
    return user;
  } on ApiException catch (e) {
    onError(e.message);
    return null;
  }
}
