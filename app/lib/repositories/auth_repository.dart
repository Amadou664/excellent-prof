import '../core/network/api_client.dart';
import '../models/enums.dart';
import '../models/user_model.dart';

/// Domaine `/auth` (voir API_CONTRACT.md).
class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// `POST /auth/register` — appelé juste après la création du compte
  /// Firebase Auth (email/mot de passe) côté client.
  ///
  /// `teacherProfile` fourni seulement si `role == PROFESSEUR`.
  /// `studentSelf` fourni si `role` in `ETUDIANT|PARTICULIER`.
  Future<UserModel> register({
    required Role role,
    required String nom,
    required String prenom,
    required String telephone,
    required String ville,
    Map<String, dynamic>? teacherProfile,
    Map<String, dynamic>? studentSelf,
  }) async {
    final body = <String, dynamic>{
      'role': role.apiValue,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'ville': ville,
      'teacherProfile': ?teacherProfile,
      'studentSelf': ?studentSelf,
    };
    final data = await _client.unwrap(
      () => _client.dio.post('/auth/register', data: body),
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /auth/me` — renvoie `User & { teacherProfile?, students?: Student[] }`.
  Future<UserModel> me() async {
    final data = await _client.unwrap(() => _client.dio.get('/auth/me'));
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// `POST /auth/fcm-token` — enregistre le token FCM courant sur `User.fcmToken`.
  Future<void> sendFcmToken(String token) async {
    await _client.unwrap(
      () => _client.dio.post('/auth/fcm-token', data: {'token': token}),
    );
  }
}
