import '../core/network/api_client.dart';
import '../models/enums.dart';
import '../models/user_model.dart';

/// Domaine `/users` (ADMIN uniquement, voir API_CONTRACT.md).
class UserRepository {
  UserRepository(this._client);

  final ApiClient _client;

  /// `GET /users?role=&status=&q=` avec pagination `?page=&pageSize=`.
  Future<List<UserModel>> list({
    Role? role,
    UserStatus? status,
    String? q,
    int page = 1,
    int pageSize = 20,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.get(
        '/users',
        queryParameters: {
          if (role != null) 'role': role.apiValue,
          if (status != null) 'status': status.apiValue,
          if (q != null && q.isNotEmpty) 'q': q,
          'page': page,
          'pageSize': pageSize,
        },
      ),
    );
    final items = (data is Map<String, dynamic> ? data['items'] : data)
        as List<dynamic>;
    return items
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `PATCH /users/:id/status` body `{ "status": "UserStatus" }`.
  Future<UserModel> updateStatus({
    required String id,
    required UserStatus status,
  }) async {
    final data = await _client.unwrap(
      () => _client.dio.patch(
        '/users/$id/status',
        data: {'status': status.apiValue},
      ),
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }
}
