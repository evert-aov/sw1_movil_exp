/// Modelo de dominio que representa una Entrada Digital con Código QR (CU-05 / HU-12).
///
/// Archivo independiente con responsabilidad única sobre los datos del pase de acceso
/// del asistente móvil.
class TicketModel {
  /// Identificador único del ticket.
  final int id;

  /// Código alfanumérico legible de la entrada (ej. EXP-2026-4812).
  final String ticketCode;

  /// Carga útil firmada codificada en el código QR para validación en puerta.
  final String qrPayload;

  /// Indica si la entrada ya fue escaneada en la puerta del establecimiento.
  final bool isUsed;

  /// Título de la experiencia asociada al ticket.
  final String experienceTitle;

  /// Nombre del establecimiento y zona del evento.
  final String venueName;

  /// Fecha y hora programada del evento.
  final DateTime eventDate;

  /// Monto total abonado por esta entrada en Bolivianos (Bs.).
  final double pricePaid;

  /// Crea una instancia inmutable de [TicketModel].
  const TicketModel({
    required this.id,
    required this.ticketCode,
    required this.qrPayload,
    required this.isUsed,
    required this.experienceTitle,
    required this.venueName,
    required this.eventDate,
    required this.pricePaid,
  });

  /// Construye un [TicketModel] desde un mapa JSON proveniente del servidor.
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int? ?? 0,
      ticketCode: json['ticket_code'] as String? ?? '',
      qrPayload: json['qr_payload'] as String? ?? '',
      isUsed: json['is_used'] as bool? ?? false,
      experienceTitle: json['experience_title'] as String? ?? '',
      venueName: json['venue_name'] as String? ?? '',
      eventDate: DateTime.tryParse(json['event_date'] as String? ?? '') ??
          DateTime.now(),
      pricePaid: (json['price_paid'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serializa el [TicketModel] a un mapa JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ticket_code': ticketCode,
      'qr_payload': qrPayload,
      'is_used': isUsed,
      'experience_title': experienceTitle,
      'venue_name': venueName,
      'event_date': eventDate.toIso8601String(),
      'price_paid': pricePaid,
    };
  }
}
