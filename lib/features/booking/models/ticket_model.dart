// Modelo de Ticket y Entrada con QR en Flutter
class TicketModel {
  final int id;
  final String ticketCode;
  final String qrPayload;
  final bool isUsed;
  final String experienceTitle;

  TicketModel({
    required this.id,
    required this.ticketCode,
    required this.qrPayload,
    required this.isUsed,
    required this.experienceTitle,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? 0,
      ticketCode: json['ticket_code'] ?? '',
      qrPayload: json['qr_payload'] ?? '',
      isUsed: json['is_used'] ?? false,
      experienceTitle: json['experience_title'] ?? '',
    );
  }
}
