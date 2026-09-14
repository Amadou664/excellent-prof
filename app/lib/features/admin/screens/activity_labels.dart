import '../../../models/activity_log_model.dart';

/// Traduit une ligne technique du journal d'activité (méthode HTTP + chemin
/// d'API, ou navigation d'écran) en une phrase française compréhensible par
/// un admin non-développeur. Le détail technique brut (verbe HTTP, route)
/// n'a aucun sens pour lui — voir la demande d'origine : "que l'utilisateur
/// [de l'app, ici l'admin] comprenne, de façon très claire".
String libelleActivite(ActivityLogModel log) {
  if (log.estUneVue) return _libelleEcran(log.path);
  return _libelleAction(log.method, log.path);
}

String libelleRole(String? role) {
  switch (role) {
    case 'PARENT':
      return 'Parent';
    case 'PROFESSEUR':
      return 'Professeur';
    case 'ETUDIANT':
      return 'Étudiant';
    case 'PARTICULIER':
      return 'Particulier';
    case 'ADMIN':
      return 'Admin';
    default:
      return '';
  }
}

String nomActeur(ActivityLogModel log) {
  if (log.utilisateur != null) return log.utilisateur!;
  if (log.path.contains('webhook')) return 'CinetPay (service de paiement)';
  return 'Visiteur non identifié';
}

String _libelleEcran(String chemin) {
  if (chemin == '/splash') return "a ouvert l'application";
  if (chemin == '/role-selection') return "a ouvert le choix de profil";
  if (chemin == '/login') return "a ouvert l'écran de connexion";
  if (chemin.startsWith('/register/')) {
    return "a ouvert le formulaire d'inscription";
  }
  if (chemin == '/pending-validation') {
    return "a consulté l'écran d'attente de validation";
  }
  if (chemin == '/connection-error') return 'a vu une erreur de connexion';
  if (chemin == '/parent' || chemin == '/teacher' || chemin == '/learner') {
    return 'a ouvert son tableau de bord';
  }
  if (chemin == '/admin') return "a ouvert l'espace admin";
  if (chemin == '/parent/ajouter-enfant') {
    return "a ouvert le formulaire d'ajout d'enfant";
  }
  if (chemin.contains('/cahier-texte')) return 'a ouvert un cahier de texte';
  if (chemin.endsWith('/demande-cours')) {
    return 'a ouvert le formulaire de nouvelle demande';
  }
  if (chemin.contains('/demande/')) return "a ouvert le détail d'une demande";
  if (chemin.startsWith('/chat/')) return 'a ouvert une conversation';
  if (chemin.startsWith('/annonces/')) return 'a ouvert une annonce';
  if (chemin == '/annonces') return 'a ouvert les annonces';
  if (chemin == '/notifications') return 'a ouvert ses notifications';
  if (chemin.endsWith('/inscription')) {
    return "s'est inscrit à un cours pour tous";
  }
  if (chemin.startsWith('/cours-pour-tous/')) {
    return 'a ouvert un cours pour tous';
  }
  if (chemin == '/cours-pour-tous') return 'a ouvert les cours pour tous';
  return "a ouvert une page de l'application";
}

String _libelleAction(String method, String path) {
  final propre = path.startsWith('/api/') ? path.substring(5) : path;
  final segments = propre.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return 'a effectué une action sur le serveur';

  final ressource = segments.first;
  final reste = segments.length > 1 ? segments.sublist(1).join('/') : '';

  switch (ressource) {
    case 'auth':
      if (reste == 'register') return 'a créé son compte';
      if (reste == 'fcm-token') {
        return 'a activé les notifications sur son téléphone';
      }
      return 'a chargé son profil';
    case 'users':
      if (reste == 'me') {
        return method == 'DELETE'
            ? 'a supprimé son compte'
            : 'a modifié son profil';
      }
      if (reste.endsWith('/status')) {
        return "a changé le statut d'un utilisateur";
      }
      if (reste.isEmpty) return 'a consulté la liste des utilisateurs';
      return 'a consulté un profil utilisateur';
    case 'teachers':
      if (reste == 'me') {
        return method == 'PATCH'
            ? 'a mis à jour son profil professeur'
            : 'a consulté son profil professeur';
      }
      if (reste.endsWith('/candidature')) {
        return 'a mis à jour une candidature de professeur';
      }
      return 'a consulté la liste des professeurs';
    case 'students':
      if (reste == 'mine') return 'a consulté ses enfants';
      if (method == 'POST') return 'a ajouté un enfant';
      if (method == 'DELETE') return 'a supprimé un enfant';
      return 'a modifié un enfant';
    case 'demandes':
      if (reste == 'mine') return 'a consulté ses demandes de cours';
      if (reste.endsWith('/assigner')) {
        return 'a assigné un professeur à une demande';
      }
      if (reste.endsWith('/confirmer')) {
        return 'a confirmé une demande de cours';
      }
      if (reste.endsWith('/refuser')) return 'a refusé une demande de cours';
      if (reste.endsWith('/annuler')) return 'a annulé une demande de cours';
      if (reste.endsWith('/paiement')) {
        return "a mis à jour le paiement d'une demande";
      }
      if (reste.endsWith('/messages')) {
        return method == 'POST'
            ? 'a envoyé un message'
            : 'a consulté une conversation';
      }
      if (reste.isEmpty && method == 'POST') {
        return 'a envoyé une nouvelle demande de cours';
      }
      return 'a consulté la file des demandes';
    case 'seances':
      if (reste == 'mine') return 'a consulté ses séances';
      if (reste.endsWith('/statut')) return "a changé le statut d'une séance";
      if (reste.endsWith('/cahier-texte')) {
        return method == 'PUT'
            ? 'a rempli un cahier de texte'
            : 'a consulté un cahier de texte';
      }
      return 'a créé une séance';
    case 'annonces':
      if (reste.isEmpty) {
        return method == 'POST'
            ? 'a publié une annonce'
            : 'a consulté les annonces';
      }
      return method == 'DELETE'
          ? 'a supprimé une annonce'
          : 'a modifié une annonce';
    case 'cours-pour-tous':
      if (reste.endsWith('/inscription')) {
        return "a inscrit un élève à un cours pour tous";
      }
      if (reste.isEmpty) {
        return method == 'POST'
            ? 'a créé un cours pour tous'
            : 'a consulté les cours pour tous';
      }
      return method == 'DELETE'
          ? 'a supprimé un cours pour tous'
          : 'a modifié un cours pour tous';
    case 'avis':
      if (reste.endsWith('/statut')) return "a changé la visibilité d'un avis";
      if (reste.isEmpty) {
        return method == 'POST' ? 'a laissé un avis' : 'a consulté les avis';
      }
      return 'a supprimé un avis';
    case 'admin':
      return 'a consulté les statistiques';
    case 'files':
      return method == 'POST' ? 'a envoyé un fichier' : 'a consulté un fichier';
    case 'notifications':
      if (reste == 'read-all') return 'a marqué ses notifications comme lues';
      if (reste.endsWith('/read')) return 'a lu une notification';
      return 'a consulté ses notifications';
    case 'signalements':
      if (reste.endsWith('/traiter')) return 'a traité un signalement';
      if (reste.isEmpty) {
        return method == 'POST'
            ? 'a signalé un utilisateur'
            : 'a consulté les signalements';
      }
      return 'a consulté les signalements';
    case 'paiements':
      if (reste == 'initier') return 'a lancé un paiement en ligne';
      if (reste.endsWith('/statut')) return "a vérifié le statut d'un paiement";
      if (reste == 'webhook') return 'a confirmé un paiement';
      return "a consulté l'historique des paiements";
    case 'activity':
      return "a consulté le journal d'activité";
  }

  final verbe = switch (method) {
    'POST' => 'a créé',
    'PATCH' || 'PUT' => 'a modifié',
    'DELETE' => 'a supprimé',
    _ => 'a consulté',
  };
  return '$verbe une information ($ressource)';
}
