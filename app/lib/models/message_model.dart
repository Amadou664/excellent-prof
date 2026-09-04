/// Message échangé entre une famille et le professeur assigné, rattaché à
/// une `Demande` (`GET/POST /demandes/:id/messages`).
class MessageModel {
  final String id;
  final String demandeId;
  final String auteurId;
  final String contenu;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.demandeId,
    required this.auteurId,
    required this.contenu,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      demandeId: json['demandeId'] as String? ?? '',
      auteurId: json['auteurId'] as String? ?? '',
      contenu: json['contenu'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
