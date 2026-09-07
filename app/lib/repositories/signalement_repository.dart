import '../core/network/api_client.dart';
import '../models/signalement_model.dart';

/// Domaine `/signalements` : signaler l'autre participant d'une demande
/// (voir conditions.html, section sécurité).
class SignalementRepository {
  SignalementRepository(this._client);

  final ApiClient _client;

  /// `POST /signalements` body `{ demandeId, motif }`. La cible (l'autre
  /// participant) est déduite côté serveur, pas besoin de la connaître ici.
  Future<void> create({required String demandeId, required String motif}) async {
    await _client.unwrap(
      () => _client.dio.post(
        '/signalements',
        data: {'demandeId': demandeId, 'motif': motif},
      ),
    );
  }

  /// `GET /signalements` (ADMIN).
  Future<List<SignalementModel>> listAll() async {
    final data = await _client.unwrap(() => _client.dio.get('/signalements'));
    return (data as List)
        .map((e) => SignalementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `PATCH /signalements/:id/traiter` (ADMIN).
  Future<void> markTraite(String id) async {
    await _client.unwrap(() => _client.dio.patch('/signalements/$id/traiter'));
  }
}
