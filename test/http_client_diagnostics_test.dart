import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:experiencia_movil/core/constants/api_constants.dart';
import 'package:experiencia_movil/core/network/http_client.dart';
import 'fixtures/diagnostic_error_contract_v1.dart';

void main() {
  setUp(() => HttpClient.setAuthToken(null));

  test(
    'generates UUID v4 request IDs and preserves valid supplied IDs',
    () async {
      final requestIds = <String?>[];
      final client = HttpClient(
        client: MockClient((request) async {
          requestIds.add(request.headers['x-request-id']);
          return http.Response('{}', 200);
        }),
      );

      await client.get('/generated');
      const callerId = '9f8c1bc8-2202-4ca1-8aa2-e61e2012b14e';
      await client.post(
        '/supplied',
        const {},
        headers: {'X-Request-ID': callerId},
      );

      expect(
        requestIds[0],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(requestIds[1], callerId);
    },
  );

  test(
    'extracts error code and request ID from body with response-header fallback',
    () async {
      final bodyException = await _exception(
        http.Response(
          jsonEncode({
            'detail': 'Invalid input',
            'code': 'COMMON.VALIDATION_ERROR',
            'request_id': '123e4567-e89b-42d3-a456-426614174000',
          }),
          422,
        ),
      );
      expect(bodyException.message, 'Invalid input');
      expect(bodyException.statusCode, 422);
      expect(bodyException.code, 'COMMON.VALIDATION_ERROR');
      expect(bodyException.requestId, '123e4567-e89b-42d3-a456-426614174000');

      final headerException = await _exception(
        http.Response(
          jsonEncode({
            'detail': 'Unavailable',
            'code': 'DEPENDENCY.UNAVAILABLE',
          }),
          503,
          headers: {'X-Request-ID': '123e4567-e89b-42d3-a456-426614174001'},
        ),
      );
      expect(headerException.code, 'DEPENDENCY.UNAVAILABLE');
      expect(headerException.requestId, '123e4567-e89b-42d3-a456-426614174001');
    },
  );

  test('keeps legacy exception message, status and string representation', () {
    const exception = ApiException('Legacy failure', statusCode: 418);
    expect(exception.message, 'Legacy failure');
    expect(exception.statusCode, 418);
    expect(exception.code, isNull);
    expect(exception.requestId, isNull);
    expect(exception.toString(), 'Legacy failure');
  });

  test('malformed and legacy error responses remain safe', () async {
    final malformed = await _exception(http.Response('not-json', 500));
    expect(malformed.message, 'Error HTTP 500');
    expect(malformed.code, isNull);

    final legacy = await _exception(
      http.Response(jsonEncode({'detail': 'Old server error'}), 400),
    );
    expect(legacy.message, 'Old server error');
    expect(legacy.code, isNull);
    expect(legacy.requestId, isNull);

    final invalidDiagnostics = await _exception(
      http.Response(
        jsonEncode({
          'detail': 'Unavailable',
          'code': 'not a code',
          'request_id': 'not-a-uuid',
        }),
        503,
      ),
    );
    expect(invalidDiagnostics.code, isNull);
    expect(invalidDiagnostics.requestId, isNull);
  });

  test('retains diagnostics from the shared FastAPI validation fixture', () async {
    final exception = await _exception(
      http.Response(jsonEncode(diagnosticErrorContractV1Fixture), 422),
    );

    expect(exception.statusCode, 422);
    expect(exception.code, 'COMMON.VALIDATION_ERROR');
    expect(exception.requestId, '123e4567-e89b-42d3-a456-426614174000');
    expect(exception.message, isNotEmpty);
  });

  test('keeps unknown but well-formed provider error codes diagnosable', () async {
    final exception = await _exception(
      http.Response(
        jsonEncode({
          'detail': 'Service temporarily unavailable',
          'code': 'VENDOR.EXTERNAL_TIMEOUT',
          'request_id': '123e4567-e89b-42d3-a456-426614174000',
        }),
        503,
      ),
    );

    expect(exception.code, 'VENDOR.EXTERNAL_TIMEOUT');
    expect(exception.requestId, '123e4567-e89b-42d3-a456-426614174000');
    expect(exception.message, 'Service temporarily unavailable');
  });

  test('builds request URLs from the configured API base URL', () async {
    Uri? requestUrl;
    final client = HttpClient(
      client: MockClient((request) async {
        requestUrl = request.url;
        return http.Response('{}', 200);
      }),
    );

    await client.get('/contract');

    expect(requestUrl, isNotNull);
    expect(requestUrl!.toString(), '${ApiConstants.baseUrl}/contract');
  });
}

Future<ApiException> _exception(http.Response response) async {
  final client = HttpClient(client: MockClient((_) async => response));
  try {
    await client.get('/test');
    fail('Expected ApiException');
  } on ApiException catch (exception) {
    return exception;
  }
}
