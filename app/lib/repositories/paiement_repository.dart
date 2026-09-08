import '../core/network/api_client.dart';
import '../models/paiement_model.dart';

/// Domaine `/paiements` : paiement en ligne (CinetPay) d'une Demande dont le
/// montant a ete fixe par un admin.
class PaiementRepository {
  PaiementRepository(this._client);

  final ApiClient _client;

  /// `POST /paiements/initier` — retourne l'URL de paiement CinetPay a ouvrir
  /// dans le navigateur.
  Future<String> initier({required String demandeId}) async {
    final data = await _client.unwrap(
      () => _client.dio.post('/paiements/initier', data: {'demandeId': demandeId}),
    );
    return data['paymentUrl'] as String;
  }

  /// `GET /paiements` (ADMIN) — historique complet, tous statuts confondus.
  Future<List<PaiementModel>> listAll() async {
    final data = await _client.unwrap(() => _client.dio.get('/paiements'));
    return (data as List)
        .map((e) => PaiementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
