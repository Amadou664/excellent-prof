import '../core/network/api_client.dart';
import '../models/annonce_model.dart';
import '../models/enums.dart';

/// Domaine `/annonces` (voir API_CONTRACT.md).
///
/// `GET /annonces` se comporte différemment selon l'authentification :
/// public -> uniquement `visibilite = PUBLIC` ; authentifié -> `PUBLIC` +
/// `CONNECTES`. Le filtrage est fait côté backend selon la présence du
/// header `Authorization` (ajouté automatiquement par [ApiClient] si un
/// utilisateur Firebase est connecté) ; rien de spécial à faire ici.
class AnnonceRepository {
  AnnonceRepository(this._client);

  final ApiClient _client;

  Future<List<AnnonceModel>> list() async {
    final data = await _client.unwrap(() => _client.dio.get('/annonces'));
    final items = (data is Map<String, dynamic> ? data['items'] : data)
        as List<dynamic>;
    return items
        .map((e) => AnnonceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /annonces` (ADMIN).
  Future<AnnonceModel> create({
    required String titre,
    required String contenu,
    required AnnonceType type,
    required Visibilite visibilite,
    String? imageUrl,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.post(
        '/annonces',
        data: AnnonceModel.writeJson(
          titre: titre,
          contenu: contenu,
          type: type,
          visibilite: visibilite,
          imageUrl: imageUrl,
        ),
      ),
    );
    return AnnonceModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /annonces/:id` (ADMIN).
  Future<AnnonceModel> update({
    required String id,
    required String titre,
    required String contenu,
    required AnnonceType type,
    required Visibilite visibilite,
    String? imageUrl,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.patch(
        '/annonces/$id',
        data: AnnonceModel.writeJson(
          titre: titre,
          contenu: contenu,
          type: type,
          visibilite: visibilite,
          imageUrl: imageUrl,
        ),
      ),
    );
    return AnnonceModel.fromJson(data as Map<String, dynamic>);
  }

  /// `DELETE /annonces/:id` (ADMIN).
  Future<void> delete(String id) async {
    await _client.unwrap(() => _client.dio.delete('/annonces/$id'));
  }
}
