import '../core/network/api_client.dart';
import '../models/demande_model.dart';
import '../models/enums.dart';

/// Domaine `/demandes` (processus de réservation, voir API_CONTRACT.md).
class DemandeRepository {
  DemandeRepository(this._client);

  final ApiClient _client;

  /// `POST /demandes` (PARENT/ETUDIANT/PARTICULIER) body
  /// `{ studentId, matiere, modePref, notes? }` -> `status = NOUVELLE`.
  Future<DemandeModel> create({
    required String studentId,
    required String matiere,
    required ModePref modePref,
    String? notes,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.post(
        '/demandes',
        data: DemandeModel.createJson(
          studentId: studentId,
          matiere: matiere,
          modePref: modePref,
          notes: notes,
        ),
      ),
    );
    return DemandeModel.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /demandes/mine` — demandes de l'utilisateur courant.
  Future<List<DemandeModel>> mine() async {
    final data = await _client.unwrap(
      () => _client.dio.get('/demandes/mine'),
    );
    final items = data as List<dynamic>;
    return items
        .map((e) => DemandeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /demandes?status=` (ADMIN) — file d'attente à traiter.
  Future<List<DemandeModel>> list({DemandeStatus? status}) async {
    final data = await _client.unwrap(
      () => _client.dio.get(
        '/demandes',
        queryParameters: {if (status != null) 'status': status.apiValue},
      ),
    );
    final items = (data is Map<String, dynamic> ? data['items'] : data)
        as List<dynamic>;
    return items
        .map((e) => DemandeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `PATCH /demandes/:id/assigner` (ADMIN) body `{ "professeurId": "uuid" }`.
  Future<DemandeModel> assigner({
    required String demandeId,
    required String professeurId,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.patch(
        '/demandes/$demandeId/assigner',
        data: {'professeurId': professeurId},
      ),
    );
    return DemandeModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /demandes/:id/confirmer` (PROFESSEUR assigné).
  Future<DemandeModel> confirmer(String demandeId) async {
    final data = await _client.unwrap(
      () => _client.dio.patch('/demandes/$demandeId/confirmer'),
    );
    return DemandeModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /demandes/:id/annuler` (propriétaire ou ADMIN).
  Future<DemandeModel> annuler(String demandeId) async {
    final data = await _client.unwrap(
      () => _client.dio.patch('/demandes/$demandeId/annuler'),
    );
    return DemandeModel.fromJson(data as Map<String, dynamic>);
  }
}
