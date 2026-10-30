import 'ticket_model.dart';

/// Reserva propia con estado canónico del servidor y sus entradas anidadas.
class BookingModel {
  final String id;
  final String title;
  final String status;
  final String? experienceStatus;
  final String currency;
  final double total;
  final int quantity;
  final DateTime? eventDate;
  final DateTime? expiresAt;
  final String? refundStatus;
  final List<TicketModel> tickets;

  BookingModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      title = json['experience_title'] as String? ?? 'Reserva',
      status = json['status'] as String,
      experienceStatus = json['experience_status'] as String?,
      currency = json['currency'] as String,
      total = (json['total_amount'] as num).toDouble(),
      quantity = json['quantity'] as int,
      eventDate = DateTime.tryParse(json['event_date'] as String? ?? ''),
      expiresAt = DateTime.tryParse(json['expires_at'] as String? ?? ''),
      refundStatus = json['refund_status'] as String?,
      tickets = (json['tickets'] as List<dynamic>? ?? <dynamic>[])
          .map((value) => TicketModel.fromJson(value as Map<String, dynamic>))
          .toList();

  bool get canPay =>
      status == 'PENDING' &&
      expiresAt != null &&
      expiresAt!.isAfter(DateTime.now());
  bool get canRefund =>
      status == 'PAID' &&
      total > 0 &&
      refundStatus == null &&
      eventDate != null &&
      eventDate!.isAfter(DateTime.now()) &&
      !tickets.any((ticket) => ticket.isUsed);
}
