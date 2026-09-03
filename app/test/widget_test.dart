// Test de fumée minimal, volontairement indépendant de Firebase.
//
// L'app complète (`ExcellentProfApp`) initialise `FirebaseAuth.instance` dès
// la première évaluation du router (redirection basée sur l'état
// d'authentification) : elle ne peut donc pas être montée dans un test
// widget tant que Firebase n'est pas configuré via `flutterfire configure`
// (voir lib/firebase_options.dart et le README). En attendant, ce test
// vérifie qu'un des widgets partagés de base se comporte correctement.

import 'package:excellent_prof/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppButton affiche son label et réagit au tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Continuer',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Continuer'), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('AppButton en isLoading désactive le tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Continuer',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(tapped, isFalse);
  });
}
