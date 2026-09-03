import 'package:flutter/widgets.dart';

import '../../../models/enums.dart';
import '../self_learner_register_form.dart';

/// Formulaire d'inscription "Je suis étudiant" (apprenant autonome, pas
/// d'enfant lié à un parent). Réutilise [SelfLearnerRegisterForm], partagé
/// avec `register_particulier_screen.dart` (seul le `role` transmis diffère).
class RegisterStudentScreen extends StatelessWidget {
  const RegisterStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SelfLearnerRegisterForm(
      role: Role.etudiant,
      title: 'Étudiant',
      description:
          'Créez votre compte pour trouver un professeur particulier et '
          'suivre votre propre cahier de texte.',
    );
  }
}
