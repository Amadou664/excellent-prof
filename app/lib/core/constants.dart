/// Constantes globales de l'application.
class AppConstants {
  AppConstants._();

  /// URL de base de l'API backend (Node/Express), déployée sur Render.
  static const String apiBaseUrl = 'https://excellent-prof-backend.onrender.com/api';

  /// Durée max d'attente pour les appels réseau.
  ///
  /// Le backend est hébergé sur le plan gratuit de Render, qui met le
  /// service en veille après une période d'inactivité : la toute première
  /// requête après une veille peut prendre jusqu'à ~50-60s le temps que le
  /// serveur redémarre. Les délais ci-dessous sont volontairement larges
  /// pour éviter un faux échec "connexion impossible" dans ce cas précis.
  static const Duration apiConnectTimeout = Duration(seconds: 60);
  static const Duration apiReceiveTimeout = Duration(seconds: 60);

  /// Nom de l'application affiché dans l'UI.
  static const String appName = "L'Excellent Prof";

  /// Pays / marché cible.
  static const String country = 'Mali';
}
