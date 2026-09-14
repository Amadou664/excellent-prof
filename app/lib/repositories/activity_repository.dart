import '../core/network/api_client.dart';
import '../models/activity_log_model.dart';

/// Domaine `/activity` : journal d'activité (ADMIN) et enregistrement des
/// vues d'écran (tout utilisateur connecté, pour sa propre navigation).
class ActivityRepository {
  ActivityRepository(this._client);

  final ApiClient _client;

  /// `GET /activity?limit=&userId=` (ADMIN).
  Future<List<ActivityLogModel>> list({String? userId}) async {
    final data = await _client.unwrap(
      () => _client.dio.get(
        '/activity',
        queryParameters: {'limit': 200, if (userId != null) 'userId': userId},
      ),
    );
    return (data as List)
        .map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /activity` body `{ ecran }` — signale une navigation. Best effort :
  /// ne doit jamais bloquer ni faire planter la navigation en cours.
  Future<void> enregistrerVue(String ecran) async {
    try {
      await _client.dio.post('/activity', data: {'ecran': ecran});
    } catch (_) {
      // Journal d'activite : jamais critique pour l'utilisateur.
    }
  }
}
