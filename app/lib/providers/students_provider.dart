import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student_model.dart';
import 'repository_providers.dart';

/// `GET /students/mine` — PARENT: ses enfants ; ETUDIANT/PARTICULIER:
/// lui-même. `autoDispose` + rafraîchi via `ref.invalidate(studentsMineProvider)`
/// après chaque création/suppression.
final studentsMineProvider = FutureProvider.autoDispose<List<StudentModel>>((
  ref,
) {
  return ref.watch(studentRepositoryProvider).mine();
});
