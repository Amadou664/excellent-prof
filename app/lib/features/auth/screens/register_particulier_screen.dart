import 'package:flutter/widgets.dart';

import '../../../models/enums.dart';
import '../self_learner_register_form.dart';

/// Formulaire d'inscription "Je suis particulier" (apprenant autonome).
/// Réutilise [SelfLearnerRegisterForm], partagé avec
/// `register_student_screen.dart` (seul le `role` transmis diffère).
class RegisterParticulierScreen extends StatelessWidget {
  const RegisterParticulierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SelfLearnerRegisterForm(
      role: Role.particulier,
      title: 'Particulier',
      description:
          'Créez votre compte pour apprendre à votre rythme avec un '
          'professeur particulier.',
    );
  }
}
