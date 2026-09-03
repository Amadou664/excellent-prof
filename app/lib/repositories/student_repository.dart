import '../core/network/api_client.dart';
import '../models/enums.dart';
import '../models/student_model.dart';

/// Domaine `/students` (voir API_CONTRACT.md).
class StudentRepository {
  StudentRepository(this._client);

  final ApiClient _client;

  /// `GET /students/mine` — PARENT: ses enfants ; ETUDIANT/PARTICULIER:
  /// lui-même en tant que `Student`.
  Future<List<StudentModel>> mine() async {
    final data = await _client.unwrap(
      () => _client.dio.get('/students/mine'),
    );
    final items = data as List<dynamic>;
    return items
        .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /students` (PARENT) body
  /// `{ nom, prenom, dateNaissance, niveau, programme }`.
  Future<StudentModel> create({
    required String nom,
    required String prenom,
    required DateTime dateNaissance,
    required Niveau niveau,
    required Programme programme,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.post(
        '/students',
        data: {
          'nom': nom,
          'prenom': prenom,
          'dateNaissance': dateNaissance.toIso8601String(),
          'niveau': niveau.apiValue,
          'programme': programme.apiValue,
        },
      ),
    );
    return StudentModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /students/:id` (propriétaire ou ADMIN).
  Future<StudentModel> update({
    required String id,
    String? nom,
    String? prenom,
    DateTime? dateNaissance,
    Niveau? niveau,
    Programme? programme,
  }) async {
    final body = <String, dynamic>{
      'nom': ?nom,
      'prenom': ?prenom,
      if (dateNaissance != null)
        'dateNaissance': dateNaissance.toIso8601String(),
      if (niveau != null) 'niveau': niveau.apiValue,
      if (programme != null) 'programme': programme.apiValue,
    };
    final data = await _client.unwrap(
      () => _client.dio.patch('/students/$id', data: body),
    );
    return StudentModel.fromJson(data as Map<String, dynamic>);
  }

  /// `DELETE /students/:id` (propriétaire ou ADMIN).
  Future<void> delete(String id) async {
    await _client.unwrap(() => _client.dio.delete('/students/$id'));
  }
}
