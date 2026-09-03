import '../core/network/api_client.dart';
import '../models/cours_pour_tous_model.dart';

/// Domaine `/cours-pour-tous` (voir API_CONTRACT.md).
class CoursPourTousRepository {
  CoursPourTousRepository(this._client);

  final ApiClient _client;

  Future<List<CoursPourTousModel>> list() async {
    final data = await _client.unwrap(
      () => _client.dio.get('/cours-pour-tous'),
    );
    final items = (data is Map<String, dynamic> ? data['items'] : data)
        as List<dynamic>;
    return items
        .map((e) => CoursPourTousModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /cours-pour-tous/:id/inscription` (utilisateur connecté) body
  /// `{ "studentId": "uuid" }`.
  Future<void> inscrire({required String coursId, required String studentId}) async {
    await _client.unwrap(
      () => _client.dio.post(
        '/cours-pour-tous/$coursId/inscription',
        data: CoursPourTousModel.inscriptionJson(studentId),
      ),
    );
  }

  /// `POST /cours-pour-tous` (ADMIN).
  Future<CoursPourTousModel> create({
    required String titre,
    required String description,
    required String matiere,
    required DateTime dateDebut,
    required DateTime dateFin,
    required num tarif,
    required int placesDisponibles,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.post(
        '/cours-pour-tous',
        data: CoursPourTousModel.writeJson(
          titre: titre,
          description: description,
          matiere: matiere,
          dateDebut: dateDebut,
          dateFin: dateFin,
          tarif: tarif,
          placesDisponibles: placesDisponibles,
        ),
      ),
    );
    return CoursPourTousModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /cours-pour-tous/:id` (ADMIN).
  Future<CoursPourTousModel> update({
    required String id,
    required String titre,
    required String description,
    required String matiere,
    required DateTime dateDebut,
    required DateTime dateFin,
    required num tarif,
    required int placesDisponibles,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.patch(
        '/cours-pour-tous/$id',
        data: CoursPourTousModel.writeJson(
          titre: titre,
          description: description,
          matiere: matiere,
          dateDebut: dateDebut,
          dateFin: dateFin,
          tarif: tarif,
          placesDisponibles: placesDisponibles,
        ),
      ),
    );
    return CoursPourTousModel.fromJson(data as Map<String, dynamic>);
  }

  /// `DELETE /cours-pour-tous/:id` (ADMIN).
  Future<void> delete(String id) async {
    await _client.unwrap(() => _client.dio.delete('/cours-pour-tous/$id'));
  }
}
