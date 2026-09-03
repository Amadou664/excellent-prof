import '../core/network/api_client.dart';
import '../models/avis_model.dart';
import '../models/enums.dart';

/// Domaine `/avis` (voir API_CONTRACT.md).
class AvisRepository {
  AvisRepository(this._client);

  final ApiClient _client;

  /// `POST /avis` (PARENT/ETUDIANT/PARTICULIER) body
  /// `{ "professeurId": "uuid", "note": 1-5, "commentaire": "string" }`.
  Future<AvisModel> create({
    required String professeurId,
    required int note,
    required String commentaire,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.post(
        '/avis',
        data: AvisModel.createJson(
          professeurId: professeurId,
          note: note,
          commentaire: commentaire,
        ),
      ),
    );
    return AvisModel.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /avis?professeurId=` — avis visibles d'un prof.
  Future<List<AvisModel>> byProfesseur(String professeurId) async {
    final data = await _client.unwrap(
      () => _client.dio.get(
        '/avis',
        queryParameters: {'professeurId': professeurId},
      ),
    );
    final items = (data is Map<String, dynamic> ? data['items'] : data)
        as List<dynamic>;
    return items
        .map((e) => AvisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /avis` sans filtre (ADMIN, modération) — API_CONTRACT.md ne
  /// documente que le filtre `?professeurId=`, supposé optionnel ici pour
  /// permettre à un admin de lister tous les avis à modérer. Si le backend
  /// exige `professeurId`, cet appel échouera proprement (l'écran affiche
  /// alors l'erreur via `ErrorState`, pas de crash).
  Future<List<AvisModel>> listAll() async {
    final data = await _client.unwrap(() => _client.dio.get('/avis'));
    final items = (data is Map<String, dynamic> ? data['items'] : data)
        as List<dynamic>;
    return items
        .map((e) => AvisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `PATCH /avis/:id/statut` (ADMIN) body `{ "statut": "VISIBLE|MASQUE" }`.
  Future<AvisModel> updateStatut({
    required String id,
    required AvisStatut statut,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.patch(
        '/avis/$id/statut',
        data: {'statut': statut.apiValue},
      ),
    );
    return AvisModel.fromJson(data as Map<String, dynamic>);
  }

  /// `DELETE /avis/:id` (ADMIN).
  Future<void> delete(String id) async {
    await _client.unwrap(() => _client.dio.delete('/avis/$id'));
  }
}
