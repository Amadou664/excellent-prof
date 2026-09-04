import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../repositories/admin_repository.dart';
import '../repositories/annonce_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/avis_repository.dart';
import '../repositories/cours_pour_tous_repository.dart';
import '../repositories/demande_repository.dart';
import '../repositories/file_repository.dart';
import '../repositories/seance_repository.dart';
import '../repositories/student_repository.dart';
import '../repositories/teacher_repository.dart';
import '../repositories/user_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient.instance);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(apiClientProvider)),
);

final teacherRepositoryProvider = Provider<TeacherRepository>(
  (ref) => TeacherRepository(ref.watch(apiClientProvider)),
);

final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepository(ref.watch(apiClientProvider)),
);

final demandeRepositoryProvider = Provider<DemandeRepository>(
  (ref) => DemandeRepository(ref.watch(apiClientProvider)),
);

final seanceRepositoryProvider = Provider<SeanceRepository>(
  (ref) => SeanceRepository(ref.watch(apiClientProvider)),
);

final annonceRepositoryProvider = Provider<AnnonceRepository>(
  (ref) => AnnonceRepository(ref.watch(apiClientProvider)),
);

final coursPourTousRepositoryProvider = Provider<CoursPourTousRepository>(
  (ref) => CoursPourTousRepository(ref.watch(apiClientProvider)),
);

final avisRepositoryProvider = Provider<AvisRepository>(
  (ref) => AvisRepository(ref.watch(apiClientProvider)),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

final fileRepositoryProvider = Provider<FileRepository>(
  (ref) => FileRepository(ref.watch(apiClientProvider)),
);
