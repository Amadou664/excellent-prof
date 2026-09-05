import 'student_model.dart';
import 'teacher_profile_model.dart';
import 'user_model.dart';

/// Fiche détaillée d'un utilisateur, réservée à l'admin.
/// `GET /users/:id`.
class UserDetailModel {
  final UserModel user;
  final TeacherProfileModel? teacherProfile;
  final List<StudentModel> students;

  /// Nombre de demandes créées pour ses élèves (pertinent si
  /// PARENT/ETUDIANT/PARTICULIER).
  final int demandesCommeFamille;

  /// Nombre de demandes qui lui ont été assignées (pertinent si PROFESSEUR).
  final int demandesCommeProf;

  /// Nombre d'avis visibles reçus (pertinent si PROFESSEUR).
  final int avisRecus;

  const UserDetailModel({
    required this.user,
    this.teacherProfile,
    required this.students,
    required this.demandesCommeFamille,
    required this.demandesCommeProf,
    required this.avisRecus,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      user: UserModel.fromJson(json),
      teacherProfile: json['teacherProfile'] != null
          ? TeacherProfileModel.fromJson(json['teacherProfile'] as Map<String, dynamic>)
          : null,
      students: (json['students'] as List<dynamic>? ?? [])
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      demandesCommeFamille: (json['demandesCommeFamille'] as num?)?.toInt() ?? 0,
      demandesCommeProf: (json['demandesCommeProf'] as num?)?.toInt() ?? 0,
      avisRecus: (json['avisRecus'] as num?)?.toInt() ?? 0,
    );
  }
}
