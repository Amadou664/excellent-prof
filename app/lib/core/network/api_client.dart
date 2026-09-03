import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import 'api_exception.dart';

/// Client HTTP unique de l'application, basé sur `dio`.
///
/// Ajoute automatiquement, via un intercepteur, le header
/// `Authorization: Bearer <Firebase ID token>` sur chaque requête sortante
/// quand un utilisateur Firebase est connecté (voir API_CONTRACT.md :
/// toutes les routes sauf `POST /auth/register` et `GET /annonces` public
/// exigent ce header — l'envoyer même quand ce n'est pas strictement requis
/// est sans danger).
class ApiClient {
  ApiClient._internal() : dio = _buildDio();

  static final ApiClient instance = ApiClient._internal();

  final Dio dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiConnectTimeout,
        receiveTimeout: AppConstants.apiReceiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (_) {
              // Le token n'a pas pu être récupéré (ex: session expirée) :
              // on laisse partir la requête sans header, le backend
              // répondra 401 le cas échéant et l'appelant gère l'erreur.
            }
          }
          handler.next(options);
        },
      ),
    );

    return dio;
  }

  /// Exécute [request] et retourne directement le contenu de `data.data`
  /// (déballe l'enveloppe `{ "data": ... }` documentée dans
  /// API_CONTRACT.md). Convertit toute [DioException] en [ApiException]
  /// exploitable par l'UI.
  Future<dynamic> unwrap(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final err = data['error'] as Map<String, dynamic>;
      return ApiException(
        code: err['code'] as String? ?? 'UNKNOWN_ERROR',
        message: err['message'] as String? ?? 'Une erreur est survenue.',
        statusCode: e.response?.statusCode,
      );
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: _networkErrorMessage(e),
      statusCode: e.response?.statusCode,
    );
  }

  String _networkErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Le serveur met trop de temps à répondre. Vérifiez votre connexion.';
      case DioExceptionType.connectionError:
        return 'Impossible de joindre le serveur. Vérifiez votre connexion internet.';
      case DioExceptionType.badCertificate:
        return 'Connexion sécurisée impossible avec le serveur.';
      case DioExceptionType.cancel:
        return 'Requête annulée.';
      case DioExceptionType.badResponse:
        return 'Réponse inattendue du serveur (${e.response?.statusCode ?? '?'}).';
      case DioExceptionType.unknown:
        return e.message ?? 'Une erreur réseau est survenue.';
    }
  }
}
