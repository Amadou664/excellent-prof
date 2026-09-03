/// Constantes globales de l'application.
///
/// IMPORTANT : `apiBaseUrl` est le point de configuration principal entre
/// environnements. `10.0.2.2` est l'adresse spéciale utilisée par l'émulateur
/// Android pour joindre le `localhost` de la machine hôte. Sur iOS
/// (simulateur) ou sur un appareil physique, il faudra adapter cette valeur
/// (ex: `http://localhost:4000/api` pour le simulateur iOS, ou l'IP LAN de
/// votre machine / une URL de déploiement pour un appareil physique).
class AppConstants {
  AppConstants._();

  /// URL de base de l'API backend (Node/Express).
  ///
  /// Valeur par défaut pensée pour un émulateur Android en développement.
  /// Changez cette constante selon votre environnement :
  /// - Émulateur Android : http://10.0.2.2:4000/api
  /// - Simulateur iOS    : http://localhost:4000/api
  /// - Appareil physique : http://IP-LAN-de-votre-machine:4000/api
  /// - Production        : https://api.excellentprof.ml/api (exemple)
  static const String apiBaseUrl = 'http://10.0.2.2:4000/api';

  /// Durée max d'attente pour les appels réseau.
  static const Duration apiConnectTimeout = Duration(seconds: 15);
  static const Duration apiReceiveTimeout = Duration(seconds: 20);

  /// Nom de l'application affiché dans l'UI.
  static const String appName = "L'Excellent Prof";

  /// Pays / marché cible.
  static const String country = 'Mali';
}
