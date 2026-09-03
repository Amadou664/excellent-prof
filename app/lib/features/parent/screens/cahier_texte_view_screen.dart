import 'package:flutter/material.dart';

import '../widgets/cahier_texte_read_view.dart';

/// Cahier de texte (lecture seule) d'un enfant précis, accessible depuis
/// `mes_enfants_screen.dart`. Le rendu est délégué à [CahierTexteReadView],
/// partagé avec l'espace Étudiant/Particulier.
class CahierTexteViewScreen extends StatelessWidget {
  const CahierTexteViewScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cahier de texte')),
      body: CahierTexteReadView(studentId: studentId),
    );
  }
}
