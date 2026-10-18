import '../models/booking_request_model.dart';
import '../models/ticket_model.dart';

/// Servicio de dominio para reservas y entradas digitales (Planificado para Sprint 2 • CU-06).
///
/// En el alcance del Sprint 1 expone únicamente las firmas documentadas de contrato
/// para mantener bajo acoplamiento entre módulos.
class BookingService {
  /// Crea una instancia de [BookingService].
  const BookingService();

  /// Firma de contrato para procesar una solicitud de reserva [request] en Sprint 2.
  Future<TicketModel?> createBooking(BookingRequestModel request) async {
    return null;
  }

  /// Firma de contrato para consultar el historial de entradas QR del asistente en Sprint 2.
  Future<List<TicketModel>> getMyTickets() async {
    return const <TicketModel>[];
  }
}
