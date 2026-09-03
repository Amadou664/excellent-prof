import '../core/network/api_client.dart';
import '../models/admin_stats_model.dart';

/// Domaine `/admin` (voir API_CONTRACT.md). La gestion des utilisateurs, des
/// enseignants, des demandes, des annonces, des campagnes et des avis vit
/// dans leurs repositories dédiés respectifs (`UserRepository`,
/// `TeacherRepository`, `DemandeRepository`, `AnnonceRepository`,
/// `CoursPourTousRepository`, `AvisRepository`) puisque ce sont les mêmes
/// routes que celles utilisées côté utilisateur final, simplement appelées
/// avec un rôle ADMIN.
class AdminRepository {
  AdminRepository(this._client);

  final ApiClient _client;

  /// `GET /admin/stats` (ADMIN).
  Future<AdminStatsModel> stats() async {
    final data = await _client.unwrap(() => _client.dio.get('/admin/stats'));
    return AdminStatsModel.fromJson(data as Map<String, dynamic>);
  }
}
