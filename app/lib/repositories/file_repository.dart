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
  ///
  /// [sensible] doit valoir `true` uniquement pour une pièce d'identité :
  /// le fichier ne sera alors plus jamais accessible sans être connecté en
  /// tant qu'ADMIN (voir [fetchProtectedBytes]), contrairement aux photos de
  /// profil/diplômes qui restent publiques.
  Future<String> upload({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    bool sensible = false,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
      'sensible': sensible.toString(),
    });
    final data = await _client.unwrap(
      () => _client.dio.post('/files', data: formData),
    );
    return (data as Map<String, dynamic>)['url'] as String;
  }

  /// Récupère les octets d'un fichier `sensible` (pièce d'identité) : ce
  /// endpoint exige une connexion ADMIN côté backend, donc à appeler
  /// uniquement via ce client (qui attache le token Firebase automatiquement)
  /// plutôt qu'en ouvrant [url] dans un navigateur externe.
  Future<List<int>> fetchProtectedBytes(String url) async {
    final response = await _client.dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}
