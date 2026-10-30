import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:experiencia_movil/core/network/http_client.dart';
import 'package:experiencia_movil/features/booking/services/booking_service.dart';
import 'package:experiencia_movil/features/booking/models/booking_request_model.dart';

void main() {
  tearDown(() => HttpClient.setAuthToken(null));
  final booking = <String, dynamic>{
    'id': 'booking',
    'status': 'PAID',
    'currency': 'BOB',
    'quantity': 1,
    'total_amount': 100,
    'experience_title': 'Taller',
    'event_date': '2030-01-01T12:00:00Z',
    'tickets': [
      {
        'id': 'ticket',
        'ticket_code': 'code',
        'qr_payload': 'signed-entry',
        'is_used': false,
      },
    ],
  };

  test(
    'sends only quantity and event with a reusable key and current JWT',
    () async {
      HttpClient.setAuthToken('test-token');
      final client = MockClient((request) async {
        expect(request.url.path, '/api/bookings');
        expect(request.headers['Idempotency-Key'], 'same-operation-key');
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {
          'experience_id': 'event',
          'quantity': 1,
        });
        return http.Response(jsonEncode(booking), 201);
      });
      final api = BookingService(httpClient: HttpClient(client: client));
      final response = await api.createBooking(
        const BookingRequestModel(experienceId: 'event'),
        'same-operation-key',
      );
      expect(response.tickets.single.qrPayload, 'signed-entry');
      expect(response.canPay, isFalse);
    },
  );

  test('rejects a payment redirect outside the Stripe host', () async {
    final api = BookingService(
      httpClient: HttpClient(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'checkout_url': 'https://example.com/payment'}),
            200,
          ),
        ),
      ),
    );
    await expectLater(api.checkout('booking'), throwsA(isA<ApiException>()));
  });
}
