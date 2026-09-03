import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error, stackTrace) {
    // ATTENDU tant que `lib/firebase_options.dart` n'a pas été régénéré via
    // `flutterfire configure` (voir le commentaire en tête de ce fichier et
    // le README). L'app démarre quand même : les écrans publics (annonces,
    // cours pour tous, sélection de profil) restent consultables, et toute
    // action nécessitant Firebase échouera avec un message d'erreur clair
    // au lieu de faire planter l'application au démarrage.
    debugPrint(
      '⚠️ Firebase.initializeApp() a échoué : $error\n'
      'Avez-vous lancé `flutterfire configure` ? (voir README.md)\n'
      '$stackTrace',
    );
  }

  runApp(const ProviderScope(child: ExcellentProfApp()));
}
