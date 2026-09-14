/// `GET /paiements/:demandeId/statut` — sert aussi de reçu une fois payé :
/// `moyenPaiement`/`transactionId` viennent du dernier paiement CinetPay
/// réussi, absents si `paye` vient d'un marquage manuel par l'admin.
class StatutPaiementModel {
  final bool paye;
  final int? montant;
  final String? moyenPaiement;
  final String? transactionId;
  final DateTime? datePaiement;

  const StatutPaiementModel({
    required this.paye,
    this.montant,
    this.moyenPaiement,
    this.transactionId,
    this.datePaiement,
  });

  factory StatutPaiementModel.fromJson(Map<String, dynamic> json) {
    return StatutPaiementModel(
      paye: json['paye'] as bool? ?? false,
      montant: json['montant'] as int?,
      moyenPaiement: json['moyenPaiement'] as String?,
      transactionId: json['transactionId'] as String?,
      datePaiement: json['datePaiement'] != null
          ? DateTime.tryParse(json['datePaiement'] as String)
          : null,
    );
  }
}
