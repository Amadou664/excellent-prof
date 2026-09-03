import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/annonce_model.dart';
import 'repository_providers.dart';

/// `GET /annonces` — le backend filtre lui-même PUBLIC / PUBLIC+CONNECTES
/// selon la présence du header d'auth.
final annoncesProvider = FutureProvider.autoDispose<List<AnnonceModel>>((
  ref,
) {
  return ref.watch(annonceRepositoryProvider).list();
});
