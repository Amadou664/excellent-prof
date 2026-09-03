// Généré par `flutterfire configure` pour le projet Firebase "excellent-prof".

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Options Firebase par défaut pour l'application courante.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions n\'a pas été configuré pour cette '
          'plateforme (${defaultTargetPlatform.name}). Relancez '
          '`flutterfire configure` en incluant cette plateforme.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIPiaobQMocLZz7FZNlUUTWcf-5eAxt2w',
    appId: '1:312273081281:android:c16a41f1357921a2635540',
    messagingSenderId: '312273081281',
    projectId: 'excellent-prof',
    storageBucket: 'excellent-prof.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKNf4cZ1s3qKfTgFZ8cNskQhHu-7LfIG4',
    appId: '1:312273081281:ios:6b9aabd6463ad724635540',
    messagingSenderId: '312273081281',
    projectId: 'excellent-prof',
    storageBucket: 'excellent-prof.firebasestorage.app',
    iosBundleId: 'com.excellentprof.excellentProf',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDH93-wLNvZn6JWq6d3xbrOnht-szUJrLk',
    appId: '1:312273081281:web:81f60d4fab71f9b5635540',
    messagingSenderId: '312273081281',
    projectId: 'excellent-prof',
    authDomain: 'excellent-prof.firebaseapp.com',
    storageBucket: 'excellent-prof.firebasestorage.app',
  );
}
