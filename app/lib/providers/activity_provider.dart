import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_log_model.dart';
import 'repository_providers.dart';

/// `GET /activity` (ADMIN).
final activityAdminProvider =
    FutureProvider.autoDispose<List<ActivityLogModel>>((ref) {
      return ref.watch(activityRepositoryProvider).list();
    });
