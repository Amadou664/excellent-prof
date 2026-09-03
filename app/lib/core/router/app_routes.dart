/// Constantes des chemins de navigation (`go_router`).
class AppRoutes {
  AppRoutes._();

  // --- Démarrage / auth ---
  static const String splash = '/splash';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String registerParent = '/register/parent';
  static const String registerTeacher = '/register/teacher';
  static const String registerStudent = '/register/student';
  static const String registerParticulier = '/register/particulier';
  static const String pendingValidation = '/pending-validation';
  static const String connectionError = '/connection-error';

  // --- Parent ---
  static const String parentDashboard = '/parent';
  static const String parentAjouterEnfant = '/parent/ajouter-enfant';
  static const String parentCahierTexte = '/parent/eleve/:studentId/cahier-texte';
  static const String parentDemandeCours = '/parent/demande-cours';
  static const String parentDemandeDetail = '/parent/demande/:demandeId';

  static String parentCahierTextePath(String studentId) =>
      '/parent/eleve/$studentId/cahier-texte';
  static String parentDemandeDetailPath(String demandeId) =>
      '/parent/demande/$demandeId';

  // --- Professeur ---
  static const String teacherDashboard = '/teacher';
  static const String teacherCahierTexteEdit = '/teacher/seance/:seanceId/cahier-texte';

  static String teacherCahierTexteEditPath(String seanceId) =>
      '/teacher/seance/$seanceId/cahier-texte';

  // --- Étudiant / particulier ---
  static const String learnerDashboard = '/learner';
  static const String learnerDemandeCours = '/learner/demande-cours';
  static const String learnerDemandeDetail = '/learner/demande/:demandeId';

  static String learnerDemandeDetailPath(String demandeId) =>
      '/learner/demande/$demandeId';

  // --- Admin ---
  static const String adminDashboard = '/admin';

  // --- Annonces ---
  static const String annonces = '/annonces';
  static const String annonceDetail = '/annonces/:id';

  static String annonceDetailPath(String id) => '/annonces/$id';

  // --- Cours pour tous ---
  static const String coursPourTous = '/cours-pour-tous';
  static const String coursPourTousDetail = '/cours-pour-tous/:id';
  static const String coursPourTousInscription = '/cours-pour-tous/:id/inscription';

  static String coursPourTousDetailPath(String id) => '/cours-pour-tous/$id';
  static String coursPourTousInscriptionPath(String id) =>
      '/cours-pour-tous/$id/inscription';
}
