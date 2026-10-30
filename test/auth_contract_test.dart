import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:experiencia_movil/core/network/http_client.dart';
import 'package:experiencia_movil/features/auth/services/auth_service.dart';
import 'package:experiencia_movil/features/auth/models/auth_credentials_model.dart';

void main() {
  setUp(() => HttpClient.setAuthToken(null));

  test(
    'login loads full profile rather than treating token metadata as User',
    () async {
      final requests = <String>[];
      final client = MockClient((request) async {
        requests.add(request.url.path);
        if (request.url.path.endsWith('/login')) {
          return http.Response(
            jsonEncode({
              'access_token': 'session-token',
              'email': 'test@example.com',
              'user_id': 'user-id',
              'roles': ['ATTENDEE'],
            }),
            200,
          );
        }
        expect(request.headers['Authorization'], 'Bearer session-token');
        return http.Response(
          jsonEncode({
            'id': 'user-id',
            'first_name': 'Nombre',
            'email': 'test@example.com',
            'roles': ['ATTENDEE'],
          }),
          200,
        );
      });
      final auth = AuthService(httpClient: HttpClient(client: client));
      final user = await auth.login(
        const AuthCredentialsModel(
          email: 'test@example.com',
          password: 'password123',
        ),
      );
      expect(user.firstName, 'Nombre');
      expect(requests.first, '/api/auth/mobile/login');
      expect(requests.last.endsWith('/users/me'), isTrue);
    },
  );

  for (final roles in <List<String>>[
    <String>['HOST'],
    <String>['ADMIN'],
    <String>['VENUE'],
    <String>[],
  ]) {
    test('rejects a profile without ATTENDEE: $roles', () async {
      final client = MockClient(
        (request) async => request.url.path.endsWith('/login')
            ? http.Response(
                jsonEncode({'access_token': 'synthetic-token'}),
                200,
              )
            : http.Response(
                jsonEncode({
                  'id': 'user',
                  'first_name': 'User',
                  'email': 'test@example.com',
                  'roles': roles,
                }),
                200,
              ),
      );
      final auth = AuthService(httpClient: HttpClient(client: client));
      await expectLater(
        auth.login(
          const AuthCredentialsModel(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        throwsA(isA<ApiException>()),
      );
      expect(auth.currentUser, isNull);
      expect(auth.isAuthenticated, isFalse);
      expect(HttpClient.authToken, isNull);
    });
  }

  test(
    'accepts HOST plus ATTENDEE and clears session after role revocation',
    () async {
      var roles = ['HOST', 'ATTENDEE'];
      final client = MockClient(
        (request) async => request.url.path.endsWith('/login')
            ? http.Response(
                jsonEncode({'access_token': 'synthetic-token'}),
                200,
              )
            : http.Response(
                jsonEncode({
                  'id': 'user',
                  'first_name': 'User',
                  'email': 'test@example.com',
                  'roles': roles,
                }),
                200,
              ),
      );
      final auth = AuthService(httpClient: HttpClient(client: client));
      final user = await auth.login(
        const AuthCredentialsModel(
          email: 'test@example.com',
          password: 'password123',
        ),
      );
      expect(user.canUseMobile, isTrue);
      expect(user.copyWith(firstName: 'Updated').roles, ['HOST', 'ATTENDEE']);
      roles = ['HOST'];
      await expectLater(auth.fetchProfile(), throwsA(isA<ApiException>()));
      expect(auth.isAuthenticated, isFalse);
      expect(HttpClient.authToken, isNull);
    },
  );

  test('logout sends JWT before clearing local session', () async {
    HttpClient.setAuthToken('session-token');
    final client = MockClient((request) async {
      expect(request.url.path.endsWith('/auth/logout'), isTrue);
      expect(request.headers['Authorization'], 'Bearer session-token');
      return http.Response('{}', 200);
    });
    final result = await AuthService(
      httpClient: HttpClient(client: client),
    ).logout();
    expect(result, isTrue);
    expect(HttpClient.authToken, isNull);
  });

  test(
    'failed server logout clears local state and reports no remote confirmation',
    () async {
      HttpClient.setAuthToken('session-token');
      final client = MockClient((request) async => http.Response('{}', 503));
      final auth = AuthService(httpClient: HttpClient(client: client));
      expect(await auth.logout(), isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(HttpClient.authToken, isNull);
    },
  );
}
