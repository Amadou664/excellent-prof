import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../core/network/api_client.dart';

/// Domaine `/files` : upload de fichiers (photos, diplômes...) stockés côté
/// backend (Neon Postgres) plutôt que sur Firebase Storage — évite d'exiger
/// une carte bancaire (palier Blaze) et fonctionne identiquement sur mobile
/// et sur le web.
class FileRepository {
  FileRepository(this._client);

  final ApiClient _client;

  /// Envoie [bytes] au backend et retourne l'URL publique du fichier stocké,
  /// à transmettre telle quelle dans les payloads attendant une URL
  /// (`photoUrl`, `diplomesUrls`).
  Future<String> upload({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    });
    final data = await _client.unwrap(
      () => _client.dio.post('/files', data: formData),
    );
    return (data as Map<String, dynamic>)['url'] as String;
  }
}
