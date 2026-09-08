import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paiement_model.dart';
import 'repository_providers.dart';

/// `GET /paiements` (ADMIN).
final paiementsAdminProvider = FutureProvider.autoDispose<List<PaiementModel>>((ref) {
  return ref.watch(paiementRepositoryProvider).listAll();
});
