import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cahier_texte_model.dart';
import '../models/seance_model.dart';
import 'repository_providers.dart';

/// `GET /seances/mine`.
final seancesMineProvider = FutureProvider.autoDispose<List<SeanceModel>>((
  ref,
) {
  return ref.watch(seanceRepositoryProvider).mine();
});

/// `GET /seances/:id/cahier-texte`.
final cahierTexteProvider = FutureProvider.autoDispose
    .family<CahierTexteModel?, String>((ref, seanceId) {
      return ref.watch(seanceRepositoryProvider).getCahierTexte(seanceId);
    });
