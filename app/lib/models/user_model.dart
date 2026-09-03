import 'enums.dart';
import 'student_model.dart';
import 'teacher_profile_model.dart';

/// Correspond au schéma `User` d'API_CONTRACT.md.
///
/// ```json
/// {
///   "id": "uuid", "firebaseUid": "string", "email": "string", "telephone": "string",
///   "nom": "string", "prenom": "string", "role": "Role", "status": "UserStatus",
///   "ville": "string", "photoUrl": "string|null", "createdAt": "ISO datetime"
/// }
/// ```
///
/// `GET /auth/me` renvoie en plus `teacherProfile?` et `students?`.
class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String telephone;
  final String nom;
  final String prenom;
  final Role role;
  final UserStatus status;
  final String ville;
  final String? photoUrl;
  final DateTime createdAt;

  /// Présent uniquement quand `role == PROFESSEUR`, renvoyé par `GET /auth/me`.
  final TeacherProfileModel? teacherProfile;

  /// Présent pour PARENT (ses enfants) ou ETUDIANT/PARTICULIER (lui-même),
  /// renvoyé par `GET /auth/me`.
  final List<StudentModel>? students;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.telephone,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.status,
    required this.ville,
    this.photoUrl,
    required this.createdAt,
    this.teacherProfile,
    this.students,
  });

  String get nomComplet => '$prenom $nom';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      role: Role.fromApi(json['role'] as String? ?? 'PARTICULIER'),
      status: UserStatus.fromApi(json['status'] as String? ?? 'EN_ATTENTE'),
      ville: json['ville'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      teacherProfile: json['teacherProfile'] != null
          ? TeacherProfileModel.fromJson(
              json['teacherProfile'] as Map<String, dynamic>,
            )
          : null,
      students: json['students'] != null
          ? (json['students'] as List<dynamic>)
                .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'telephone': telephone,
      'nom': nom,
      'prenom': prenom,
      'role': role.apiValue,
      'status': status.apiValue,
      'ville': ville,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? telephone,
    String? nom,
    String? prenom,
    Role? role,
    UserStatus? status,
    String? ville,
    String? photoUrl,
    DateTime? createdAt,
    TeacherProfileModel? teacherProfile,
    List<StudentModel>? students,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      role: role ?? this.role,
      status: status ?? this.status,
      ville: ville ?? this.ville,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      teacherProfile: teacherProfile ?? this.teacherProfile,
      students: students ?? this.students,
    );
  }
}
