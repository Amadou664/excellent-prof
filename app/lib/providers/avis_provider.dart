import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/avis_model.dart';
import 'repository_providers.dart';

/// `GET /avis?professeurId=`.
final avisByProfesseurProvider = FutureProvider.autoDispose
    .family<List<AvisModel>, String>((ref, professeurId) {
      return ref.watch(avisRepositoryProvider).byProfesseur(professeurId);
    });

/// `GET /avis` sans filtre (ADMIN, modération). Voir note dans
/// `AvisRepository.listAll`.
final avisAllProvider = FutureProvider.autoDispose<List<AvisModel>>((ref) {
  return ref.watch(avisRepositoryProvider).listAll();
});
