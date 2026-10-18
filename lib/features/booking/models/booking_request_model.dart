/// Modelo de solicitud de reserva y pago de cupos (CU-05 / HU-06).
///
/// Separado en su propio archivo siguiendo el principio de responsabilidad única
/// para encapsular los datos de checkout del asistente móvil.
class BookingRequestModel {
  /// Identificador de la experiencia que se desea reservar (UUID).
  final String experienceId;

  /// Cantidad de plazas solicitadas por el asistente.
  final int quantity;

  /// Monto unitario por entrada en Bolivianos (Bs.).
  final double unitPrice;

  /// Identificador simbólico del método de pago seguro (Stripe).
  final String paymentMethodId;

  /// Construye una instancia de [BookingRequestModel].
  const BookingRequestModel({
    required this.experienceId,
    this.quantity = 1,
    required this.unitPrice,
    this.paymentMethodId = 'pm_card_visa_4242',
  });

  /// Calcula el importe total a pagar multiplicando [unitPrice] por [quantity].
  double get totalAmount => unitPrice * quantity;

  /// Convierte la solicitud de reserva a formato JSON para envío al endpoint de pagos.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'experience_id': experienceId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'payment_method_id': paymentMethodId,
    };
  }
}
