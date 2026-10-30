/// Entrada anidada en una reserva: conserva exactamente los campos emitidos por la API.
class TicketModel {
  final String id;
  final String ticketCode;
  final String qrPayload;
  final bool isUsed;
  final DateTime? usedAt;
  const TicketModel({
    required this.id,
    required this.ticketCode,
    required this.qrPayload,
    required this.isUsed,
    this.usedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: json['id'] as String,
    ticketCode: json['ticket_code'] as String,
    qrPayload: json['qr_payload'] as String,
    isUsed: json['is_used'] as bool? ?? false,
    usedAt: DateTime.tryParse(json['used_at'] as String? ?? ''),
  );
}
