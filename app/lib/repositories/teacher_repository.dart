import '../core/network/api_client.dart';
import '../models/enums.dart';
import '../models/teacher_profile_model.dart';

/// Domaine `/teachers` (voir API_CONTRACT.md).
class TeacherRepository {
  TeacherRepository(this._client);

  final ApiClient _client;

  /// `GET /teachers/me` (PROFESSEUR) — profil + candidature.
  Future<TeacherProfileModel> me() async {
    final data = await _client.unwrap(() => _client.dio.get('/teachers/me'));
    return TeacherProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /teachers/me` body `{ specialites?, bio?, disponibilites?, zoneGeo? }`.
  Future<TeacherProfileModel> updateMe({
    List<String>? specialites,
    String? bio,
    Map<String, List<String>>? disponibilites,
    String? zoneGeo,
  }) async {
    final body = TeacherProfileModel.updateJson(
      specialites: specialites,
      bio: bio,
      disponibilites: disponibilites,
      zoneGeo: zoneGeo,
    );
    final data = await _client.unwrap(
      () => _client.dio.patch('/teachers/me', data: body),
    );
    return TeacherProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /teachers?statutCandidature=&specialite=&ville=` (ADMIN).
  Future<List<TeacherProfileModel>> list({
    StatutCandidature? statutCandidature,
    String? specialite,
    String? ville,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.get(
        '/teachers',
        queryParameters: {
          if (statutCandidature != null)
            'statutCandidature': statutCandidature.apiValue,
          if (specialite != null && specialite.isNotEmpty)
            'specialite': specialite,
          if (ville != null && ville.isNotEmpty) 'ville': ville,
        },
      ),
    );
    final items = (data is Map<String, dynamic> ? data['items'] : data)
        as List<dynamic>;
    return items
        .map((e) => TeacherProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `PATCH /teachers/:id/candidature` (ADMIN) body
  /// `{ "statutCandidature": "VALIDEE|REFUSEE|ENTRETIEN" }`.
  Future<TeacherProfileModel> updateCandidature({
    required String teacherId,
    required StatutCandidature statutCandidature,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.patch(
        '/teachers/$teacherId/candidature',
        data: {'statutCandidature': statutCandidature.apiValue},
      ),
    );
    return TeacherProfileModel.fromJson(data as Map<String, dynamic>);
  }
}
