import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_stats_model.dart';
import '../models/enums.dart';
import 'repository_providers.dart';

/// `GET /admin/stats` (ADMIN).
final adminStatsProvider = FutureProvider.autoDispose<AdminStatsModel>((ref) {
  return ref.watch(adminRepositoryProvider).stats();
});

/// Filtres pour `GET /users` (ADMIN).
class UserFilter {
  final Role? role;
  final UserStatus? status;
  final String? q;

  const UserFilter({this.role, this.status, this.q});

  @override
  bool operator ==(Object other) =>
      other is UserFilter &&
      other.role == role &&
      other.status == status &&
      other.q == q;

  @override
  int get hashCode => Object.hash(role, status, q);
}
