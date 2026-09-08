/// `GET /paiements` (ADMIN) : une tentative de paiement CinetPay pour une
/// Demande, quel que soit son statut (y compris echoue/en attente).
class PaiementModel {
  final String id;
  final String demandeId;
  final String matiere;
  final String eleve;
  final String? professeur;
  final int montant;
  final String devise;
  final String statut;
  final String? moyenPaiement;
  final String transactionId;
  final DateTime createdAt;

  const PaiementModel({
    required this.id,
    required this.demandeId,
    required this.matiere,
    required this.eleve,
    this.professeur,
    required this.montant,
    required this.devise,
    required this.statut,
    this.moyenPaiement,
    required this.transactionId,
    required this.createdAt,
  });

  bool get estReussi => statut == 'REUSSI';
  bool get estEchoue => statut == 'ECHOUE';

  factory PaiementModel.fromJson(Map<String, dynamic> json) {
    return PaiementModel(
      id: json['id'] as String,
      demandeId: json['demandeId'] as String,
      matiere: json['matiere'] as String? ?? '',
      eleve: json['eleve'] as String? ?? '',
      professeur: json['professeur'] as String?,
      montant: json['montant'] as int? ?? 0,
      devise: json['devise'] as String? ?? 'XOF',
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      moyenPaiement: json['moyenPaiement'] as String?,
      transactionId: json['transactionId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
