import '../core/network/api_client.dart';
import '../models/cahier_texte_model.dart';
import '../models/enums.dart';
import '../models/seance_model.dart';

/// Domaine `/seances` + `/cahier-texte` (voir API_CONTRACT.md).
class SeanceRepository {
  SeanceRepository(this._client);

  final ApiClient _client;

  /// `GET /seances/mine` — PROFESSEUR: ses séances ;
  /// PARENT/ETUDIANT/PARTICULIER: séances de leurs students.
  Future<List<SeanceModel>> mine() async {
    final data = await _client.unwrap(() => _client.dio.get('/seances/mine'));
    final items = data as List<dynamic>;
    return items
        .map((e) => SeanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /seances` (PROFESSEUR ou ADMIN) body `{ demandeId, dateSeance }`.
  Future<SeanceModel> create({
    required String demandeId,
    required DateTime dateSeance,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.post(
        '/seances',
        data: SeanceModel.createJson(
          demandeId: demandeId,
          dateSeance: dateSeance,
        ),
      ),
    );
    return SeanceModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PATCH /seances/:id/statut` body `{ "statut": "EFFECTUEE|ANNULEE" }`.
  Future<SeanceModel> updateStatut({
    required String seanceId,
    required SeanceStatut statut,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.patch(
        '/seances/$seanceId/statut',
        data: {'statut': statut.apiValue},
      ),
    );
    return SeanceModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PUT /seances/:id/cahier-texte` (PROFESSEUR assigné à la séance) — upsert.
  Future<CahierTexteModel> upsertCahierTexte({
    required String seanceId,
    required String contenu,
    required String exercices,
    required String devoirs,
    required String observations,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.put(
        '/seances/$seanceId/cahier-texte',
        data: CahierTexteModel.upsertJson(
          contenu: contenu,
          exercices: exercices,
          devoirs: devoirs,
          observations: observations,
        ),
      ),
    );
    return CahierTexteModel.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /seances/:id/cahier-texte` (PROFESSEUR concerné, PARENT du student, ADMIN).
  Future<CahierTexteModel?> getCahierTexte(String seanceId) async {
    final data = await _client.unwrap(
      () => _client.dio.get('/seances/$seanceId/cahier-texte'),
    );
    if (data == null) return null;
    return CahierTexteModel.fromJson(data as Map<String, dynamic>);
  }
}
