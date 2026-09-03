/// Enums partagés avec le backend (voir API_CONTRACT.md).
///
/// Chaque enum expose :
/// - `apiValue` : la chaîne EXACTE échangée avec l'API (ex: "EN_ATTENTE").
/// - `fromApi(String)` : parseur tolérant (retourne une valeur "inconnue"
///   raisonnable plutôt que de planter si le backend ajoute une valeur).
library;

/// `Role`: PARENT | PROFESSEUR | ETUDIANT | PARTICULIER | ADMIN
enum Role {
  parent,
  professeur,
  etudiant,
  particulier,
  admin;

  String get apiValue => switch (this) {
    Role.parent => 'PARENT',
    Role.professeur => 'PROFESSEUR',
    Role.etudiant => 'ETUDIANT',
    Role.particulier => 'PARTICULIER',
    Role.admin => 'ADMIN',
  };

  static Role fromApi(String value) {
    return Role.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => Role.particulier,
    );
  }

  String get label => switch (this) {
    Role.parent => 'Parent',
    Role.professeur => 'Professeur',
    Role.etudiant => 'Étudiant',
    Role.particulier => 'Particulier',
    Role.admin => 'Administrateur',
  };
}

/// `UserStatus`: ACTIF | EN_ATTENTE | SUSPENDU | DESACTIVE
enum UserStatus {
  actif,
  enAttente,
  suspendu,
  desactive;

  String get apiValue => switch (this) {
    UserStatus.actif => 'ACTIF',
    UserStatus.enAttente => 'EN_ATTENTE',
    UserStatus.suspendu => 'SUSPENDU',
    UserStatus.desactive => 'DESACTIVE',
  };

  static UserStatus fromApi(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => UserStatus.enAttente,
    );
  }

  String get label => switch (this) {
    UserStatus.actif => 'Actif',
    UserStatus.enAttente => 'En attente',
    UserStatus.suspendu => 'Suspendu',
    UserStatus.desactive => 'Désactivé',
  };
}

/// `Niveau`: FONDAMENTAL | COLLEGE | LYCEE | SUPERIEUR
enum Niveau {
  fondamental,
  college,
  lycee,
  superieur;

  String get apiValue => switch (this) {
    Niveau.fondamental => 'FONDAMENTAL',
    Niveau.college => 'COLLEGE',
    Niveau.lycee => 'LYCEE',
    Niveau.superieur => 'SUPERIEUR',
  };

  static Niveau fromApi(String value) {
    return Niveau.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => Niveau.fondamental,
    );
  }

  String get label => switch (this) {
    Niveau.fondamental => 'Fondamental',
    Niveau.college => 'Collège',
    Niveau.lycee => 'Lycée',
    Niveau.superieur => 'Supérieur',
  };
}

/// `Programme`: FRANCAIS | MALIEN
enum Programme {
  francais,
  malien;

  String get apiValue => switch (this) {
    Programme.francais => 'FRANCAIS',
    Programme.malien => 'MALIEN',
  };

  static Programme fromApi(String value) {
    return Programme.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => Programme.malien,
    );
  }

  String get label => switch (this) {
    Programme.francais => 'Programme français',
    Programme.malien => 'Programme malien',
  };
}

/// `ModePref`: DOMICILE | LIGNE | GROUPE
enum ModePref {
  domicile,
  ligne,
  groupe;

  String get apiValue => switch (this) {
    ModePref.domicile => 'DOMICILE',
    ModePref.ligne => 'LIGNE',
    ModePref.groupe => 'GROUPE',
  };

  static ModePref fromApi(String value) {
    return ModePref.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => ModePref.domicile,
    );
  }

  String get label => switch (this) {
    ModePref.domicile => 'À domicile',
    ModePref.ligne => 'En ligne',
    ModePref.groupe => 'En groupe',
  };
}

/// `DemandeStatus`: NOUVELLE | PROF_PROPOSE | CONFIRMEE | EN_COURS | TERMINEE | ANNULEE
enum DemandeStatus {
  nouvelle,
  profPropose,
  confirmee,
  enCours,
  terminee,
  annulee;

  String get apiValue => switch (this) {
    DemandeStatus.nouvelle => 'NOUVELLE',
    DemandeStatus.profPropose => 'PROF_PROPOSE',
    DemandeStatus.confirmee => 'CONFIRMEE',
    DemandeStatus.enCours => 'EN_COURS',
    DemandeStatus.terminee => 'TERMINEE',
    DemandeStatus.annulee => 'ANNULEE',
  };

  static DemandeStatus fromApi(String value) {
    return DemandeStatus.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => DemandeStatus.nouvelle,
    );
  }

  String get label => switch (this) {
    DemandeStatus.nouvelle => 'Nouvelle',
    DemandeStatus.profPropose => 'Professeur proposé',
    DemandeStatus.confirmee => 'Confirmée',
    DemandeStatus.enCours => 'En cours',
    DemandeStatus.terminee => 'Terminée',
    DemandeStatus.annulee => 'Annulée',
  };
}

/// `StatutCandidature`: SOUMISE | ENTRETIEN | VALIDEE | REFUSEE
enum StatutCandidature {
  soumise,
  entretien,
  validee,
  refusee;

  String get apiValue => switch (this) {
    StatutCandidature.soumise => 'SOUMISE',
    StatutCandidature.entretien => 'ENTRETIEN',
    StatutCandidature.validee => 'VALIDEE',
    StatutCandidature.refusee => 'REFUSEE',
  };

  static StatutCandidature fromApi(String value) {
    return StatutCandidature.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => StatutCandidature.soumise,
    );
  }

  String get label => switch (this) {
    StatutCandidature.soumise => 'Candidature soumise',
    StatutCandidature.entretien => 'Entretien en cours',
    StatutCandidature.validee => 'Candidature validée',
    StatutCandidature.refusee => 'Candidature refusée',
  };
}

/// `AnnonceType`: RECRUTEMENT | FORMATION | EVENEMENT | RESULTAT | INFO
enum AnnonceType {
  recrutement,
  formation,
  evenement,
  resultat,
  info;

  String get apiValue => switch (this) {
    AnnonceType.recrutement => 'RECRUTEMENT',
    AnnonceType.formation => 'FORMATION',
    AnnonceType.evenement => 'EVENEMENT',
    AnnonceType.resultat => 'RESULTAT',
    AnnonceType.info => 'INFO',
  };

  static AnnonceType fromApi(String value) {
    return AnnonceType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => AnnonceType.info,
    );
  }

  String get label => switch (this) {
    AnnonceType.recrutement => 'Recrutement',
    AnnonceType.formation => 'Formation',
    AnnonceType.evenement => 'Événement',
    AnnonceType.resultat => 'Résultat',
    AnnonceType.info => 'Information',
  };
}

/// `Visibilite`: PUBLIC | CONNECTES
enum Visibilite {
  public,
  connectes;

  String get apiValue => switch (this) {
    Visibilite.public => 'PUBLIC',
    Visibilite.connectes => 'CONNECTES',
  };

  static Visibilite fromApi(String value) {
    return Visibilite.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => Visibilite.public,
    );
  }

  String get label => switch (this) {
    Visibilite.public => 'Public',
    Visibilite.connectes => 'Utilisateurs connectés',
  };
}

/// `AvisStatut`: VISIBLE | MASQUE
enum AvisStatut {
  visible,
  masque;

  String get apiValue => switch (this) {
    AvisStatut.visible => 'VISIBLE',
    AvisStatut.masque => 'MASQUE',
  };

  static AvisStatut fromApi(String value) {
    return AvisStatut.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => AvisStatut.visible,
    );
  }

  String get label => switch (this) {
    AvisStatut.visible => 'Visible',
    AvisStatut.masque => 'Masqué',
  };
}

/// `SeanceStatut` : NON explicitement défini dans API_CONTRACT.md (le schéma
/// JSON de `Seance` n'y est pas fourni, seuls les endpoints le sont). On
/// déduit un statut initial `PLANIFIEE` en plus des deux valeurs citées dans
/// `PATCH /seances/:id/statut` (`EFFECTUEE|ANNULEE`). À harmoniser avec le
/// backend une fois son schéma réel connu.
enum SeanceStatut {
  planifiee,
  effectuee,
  annulee;

  String get apiValue => switch (this) {
    SeanceStatut.planifiee => 'PLANIFIEE',
    SeanceStatut.effectuee => 'EFFECTUEE',
    SeanceStatut.annulee => 'ANNULEE',
  };

  static SeanceStatut fromApi(String value) {
    return SeanceStatut.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => SeanceStatut.planifiee,
    );
  }

  String get label => switch (this) {
    SeanceStatut.planifiee => 'Planifiée',
    SeanceStatut.effectuee => 'Effectuée',
    SeanceStatut.annulee => 'Annulée',
  };
}
