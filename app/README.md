# L'Excellent Prof — App mobile Flutter

Application mobile (Android/iOS) de mise en relation profs/élèves au Mali,
avec 5 espaces utilisateurs : Parent, Professeur, Étudiant, Particulier,
Admin.

Cette app consomme l'API Node/Express décrite dans `API_CONTRACT.md` (à la
racine du dépôt, un niveau au-dessus de ce dossier).

## Stack

- Flutter 3.38 (Android/iOS)
- State management : Riverpod (`flutter_riverpod`)
- Routing : `go_router` (redirections basées sur l'état Firebase Auth + le
  profil/rôle/statut renvoyé par le backend)
- Réseau : `dio` avec intercepteur d'authentification (Firebase ID token)
- Firebase : `firebase_core`, `firebase_auth`, `firebase_storage`,
  `firebase_messaging`

## ⚠️ Étape obligatoire avant de lancer l'app : configurer Firebase

Ce projet a été généré **sans** accès à un compte Google/Firebase réel. Le
fichier `lib/firebase_options.dart` est donc un **placeholder** : l'app
compile et s'analyse normalement, mais `Firebase.initializeApp()`
échouera au démarrage tant que vous n'aurez pas suivi ces étapes :

1. Créer un projet sur [console.firebase.google.com](https://console.firebase.google.com).
2. Dans ce projet, activer :
   - **Authentication** → méthode "Email/Mot de passe".
   - **Storage** (pour l'upload des photos de profil et des diplômes/documents des profs).
   - **Cloud Messaging** (notifications push).
3. Installer la CLI FlutterFire (une seule fois) :
   ```
   dart pub global activate flutterfire_cli
   ```
4. Depuis ce dossier (`app/`), lancer :
   ```
   flutterfire configure
   ```
   Choisissez votre projet Firebase, puis les plateformes `android` et
   `ios`. Cette commande va :
   - régénérer `lib/firebase_options.dart` avec vos vraies clés d'API ;
   - déposer `android/app/google-services.json` ;
   - déposer `ios/Runner/GoogleService-Info.plist`.
5. Sur Android, vérifiez que `android/build.gradle` et
   `android/app/build.gradle` contiennent bien le plugin Google Services
   (normalement ajouté automatiquement par `flutterfire configure` /
   `flutter pub get` selon la version des templates Flutter).

Une fois cette étape faite, l'authentification, l'upload de fichiers et les
notifications push fonctionneront normalement.

## Configurer l'URL de l'API backend

Le point de configuration unique est `lib/core/constants.dart` :

```dart
static const String apiBaseUrl = 'http://10.0.2.2:4000/api';
```

- Émulateur Android : `http://10.0.2.2:4000/api` (valeur par défaut — `10.0.2.2`
  est l'alias spécial vers le `localhost` de la machine hôte).
- Simulateur iOS : `http://localhost:4000/api`.
- Appareil physique : `http://<IP-LAN-de-votre-machine>:4000/api`.
- Production : l'URL de déploiement du backend.

## Lancer le projet

```
flutter pub get
flutter analyze
flutter run
```

(Ce dépôt n'a pas lancé `flutter run` ni d'émulateur — seuls `pub get` et
`analyze` ont été vérifiés lors de la génération de ce scaffold.)

## Structure du code

```
lib/
  main.dart, app.dart              Point d'entrée + MaterialApp.router
  firebase_options.dart            PLACEHOLDER — voir section ci-dessus
  core/
    constants.dart                 URL API, timeouts, nom de l'app
    theme/                         Couleurs (vert foncé + doré) + ThemeData
    router/                        go_router + logique de redirection
    network/                       Client dio + intercepteur token + erreurs
    firebase/                      Wrappers auth/storage/messaging Firebase
  models/                          fromJson/toJson calqués sur API_CONTRACT.md
  repositories/                    Un par domaine, typé, appelle l'API
  providers/                       Riverpod (auth, repositories, par domaine)
  features/
    auth/                          Sélection de profil, login, 4 inscriptions,
                                    candidature en attente
    parent/                        Enfants, cahier de texte (lecture),
                                    demande de cours
    teacher/                       Élèves, cahier de texte (édition),
                                    disponibilités, candidature
    learner/                       Équivalent Parent pour étudiant/particulier
                                    (réutilise les widgets `features/parent/widgets`)
    admin/                         Stats, utilisateurs, candidatures,
                                    attribution, annonces, cours pour tous, avis
    annonces/, cours_pour_tous/    Contenus publics/connectés
    avis/                          Formulaire + liste d'avis (widgets réutilisables)
  widgets/                         Composants UI partagés
```

## Notes / écarts connus par rapport à `API_CONTRACT.md`

Voir le rapport de livraison pour le détail complet. En résumé :

- `Seance` et `Avis` n'ont pas de schéma JSON complet documenté dans
  `API_CONTRACT.md` (seuls les endpoints et certains payloads le sont) : les
  modèles `SeanceModel` / `AvisModel` déduisent des champs raisonnables et
  restent tolérants au parsing (`fromJson` n'échoue pas sur des champs
  manquants).
- Aucun endpoint `GET /annonces/:id` ni `GET /cours-pour-tous/:id` n'est
  documenté : les écrans de détail réutilisent la liste déjà chargée et
  filtrent par identifiant.
- La découverte, côté PROFESSEUR, des demandes qui lui ont été proposées
  (`PROF_PROPOSE`, avant confirmation) n'est pas couverte par un endpoint
  documenté : l'app réutilise `GET /demandes/mine` en supposant qu'il est
  étendu pour ce rôle côté backend ; sinon cette section reste simplement
  vide (pas de crash).
- `GET /avis` est appelé sans paramètre pour la modération admin (liste
  complète), en supposant `professeurId` optionnel.
