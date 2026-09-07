import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/signalement_model.dart';
import 'repository_providers.dart';

/// `GET /signalements` (ADMIN).
final signalementsProvider = FutureProvider.autoDispose<List<SignalementModel>>((ref) {
  return ref.watch(signalementRepositoryProvider).listAll();
});
