import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demande_model.dart';
import '../models/enums.dart';
import 'repository_providers.dart';

/// `GET /demandes/mine`.
final demandesMineProvider = FutureProvider.autoDispose<List<DemandeModel>>((
  ref,
) {
  return ref.watch(demandeRepositoryProvider).mine();
});

/// `GET /demandes?status=` (ADMIN).
final demandesAdminProvider = FutureProvider.autoDispose
    .family<List<DemandeModel>, DemandeStatus?>((ref, status) {
      return ref.watch(demandeRepositoryProvider).list(status: status);
    });
