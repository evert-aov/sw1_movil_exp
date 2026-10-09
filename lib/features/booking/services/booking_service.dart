import '../models/ticket_model.dart';

// Servicio de reservas y tickets: únicamente firmas de métodos (CU-05, CU-06)
class BookingService {
  Future<String?> createBooking(int experienceId, int quantity) async {
    // Firma para crear reserva e iniciar pasarela de pagos
    return null;
  }

  Future<List<TicketModel>> getMyTickets() async {
    // Firma para obtener historial de entradas adquiridas
    return [];
  }
}
