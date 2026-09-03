/// Exception représentant une erreur renvoyée par l'API selon le format
/// standard décrit dans API_CONTRACT.md :
/// `{ "error": { "code": string, "message": string } }`.
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({required this.code, required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($code): $message';
}
