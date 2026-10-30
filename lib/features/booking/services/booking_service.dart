import '../../../core/network/http_client.dart';
import '../../../core/network/request_key.dart';
import '../models/booking_request_model.dart';
import '../models/booking_model.dart';

/// Reservas, checkout y conciliación usan la identidad JWT del cliente compartido.
class BookingService {
  final HttpClient _client;
  BookingService({HttpClient? httpClient})
    : _client = httpClient ?? HttpClient();

  /// Una clave se conserva durante todos los reintentos de la misma solicitud.
  static String newKey() => newRequestKey();

  Future<BookingModel> createBooking(
    BookingRequestModel request,
    String key,
  ) async {
    final result = await _client.post(
      '/bookings',
      request.toJson(),
      headers: {'Idempotency-Key': key},
    );
    return BookingModel.fromJson(result as Map<String, dynamic>);
  }

  Future<List<BookingModel>> getMyTickets() async {
    final result = await _client.get('/bookings/my-tickets') as List<dynamic>;
    return result
        .map((value) => BookingModel.fromJson(value as Map<String, dynamic>))
        .toList();
  }

  Future<BookingModel> getBooking(String id) async => BookingModel.fromJson(
    await _client.get('/bookings/$id') as Map<String, dynamic>,
  );

  Future<BookingModel> reconcile(String id) async => BookingModel.fromJson(
    await _client.post('/payments/status/$id', {}) as Map<String, dynamic>,
  );

  Future<BookingModel> cancel(String id) async => BookingModel.fromJson(
    await _client.post('/bookings/$id/cancel', {}) as Map<String, dynamic>,
  );

  Future<BookingModel> refund(String id) async => BookingModel.fromJson(
    await _client.post('/payments/refund/$id', {}) as Map<String, dynamic>,
  );

  Future<Uri> checkout(String id) async {
    final result =
        await _client.post('/payments/checkout/$id', {})
            as Map<String, dynamic>;
    final target = Uri.parse(result['checkout_url'] as String);
    if (target.scheme != 'https' || target.host != 'checkout.stripe.com') {
      throw const ApiException('La dirección de pago recibida no es válida.');
    }
    return target;
  }
}
