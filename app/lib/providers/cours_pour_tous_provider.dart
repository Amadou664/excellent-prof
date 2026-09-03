import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cours_pour_tous_model.dart';
import 'repository_providers.dart';

/// `GET /cours-pour-tous`.
final coursPourTousProvider =
    FutureProvider.autoDispose<List<CoursPourTousModel>>((ref) {
      return ref.watch(coursPourTousRepositoryProvider).list();
    });
