import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/teacher_profile_model.dart';
import 'repository_providers.dart';

/// `GET /teachers/me` (PROFESSEUR) — profil + candidature.
final teacherMeProvider = FutureProvider.autoDispose<TeacherProfileModel>((
  ref,
) {
  return ref.watch(teacherRepositoryProvider).me();
});

/// Filtres pour `GET /teachers` (ADMIN).
class TeacherFilter {
  final StatutCandidature? statutCandidature;
  final String? specialite;
  final String? ville;

  const TeacherFilter({this.statutCandidature, this.specialite, this.ville});

  @override
  bool operator ==(Object other) =>
      other is TeacherFilter &&
      other.statutCandidature == statutCandidature &&
      other.specialite == specialite &&
      other.ville == ville;

  @override
  int get hashCode => Object.hash(statutCandidature, specialite, ville);
}

/// `GET /teachers?statutCandidature=&specialite=&ville=` (ADMIN).
final teachersAdminProvider = FutureProvider.autoDispose
    .family<List<TeacherProfileModel>, TeacherFilter>((ref, filter) {
      return ref
          .watch(teacherRepositoryProvider)
          .list(
            statutCandidature: filter.statutCandidature,
            specialite: filter.specialite,
            ville: filter.ville,
          );
    });
