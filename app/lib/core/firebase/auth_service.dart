import 'package:firebase_auth/firebase_auth.dart';

/// Fine couche au-dessus de `firebase_auth` (email/mot de passe uniquement,
/// conformément à la spec produit).
class AuthService {
  AuthService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  /// Flux de l'état de connexion Firebase, consommé par le router pour ses
  /// redirections.
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isSignedIn => _firebaseAuth.currentUser != null;

  Future<String?> getIdToken({bool forceRefresh = false}) {
    final user = _firebaseAuth.currentUser;
    if (user == null) return Future.value(null);
    return user.getIdToken(forceRefresh);
  }

  /// Crée le compte Firebase Auth (première étape de chaque formulaire
  /// d'inscription, avant l'appel à `POST /auth/register`).
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  /// Supprime le compte Firebase courant. Utilisé pour "annuler" une
  /// inscription si la création du profil côté backend échoue après la
  /// création du compte Firebase (évite un compte Firebase orphelin).
  Future<void> deleteCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Traduit les codes d'erreur `FirebaseAuthException` en messages lisibles
  /// en français pour l'utilisateur final.
  String messageFromException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-email':
        return "L'adresse email est invalide.";
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum).';
      case 'user-not-found':
        return 'Aucun compte ne correspond à cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Vérifiez votre connexion internet.';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour effectuer cette action.';
      default:
        return e.message ?? 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}
