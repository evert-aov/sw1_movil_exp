import 'dart:async';
import 'dart:convert';

import 'package:experiencia_movil/core/network/http_client.dart';
import 'package:experiencia_movil/features/live/models/live_telemetry_model.dart';
import 'package:experiencia_movil/features/live/screens/live_monitor_screen.dart';
import 'package:experiencia_movil/features/live/services/live_telemetry_service.dart';
import 'package:experiencia_movil/features/live/widgets/pulse_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// JSON de una instantánea de telemetría como la emite el backend (HU-17).
Map<String, dynamic> snapshotJson({
  String light = 'GREEN',
  double energy = 0.82,
  String status = 'LIVE',
}) {
  return <String, dynamic>{
    'type': 'telemetry',
    'session_id': 'session-1',
    'emitted_at': '2026-11-17T20:01:00Z',
    'interval_seconds': 2.5,
    'signal_status': status,
    'energy_score': energy,
    'traffic_light': light,
    'trend': 'RISING',
    'attention_score': 0.8,
    'joy_score': 0.7,
    'detected_faces_count': 14,
    'dominant_age_group': 'YOUNG_ADULT',
    'last_metric_at': '2026-11-17T20:01:00Z',
    'pulse': <Map<String, dynamic>>[
      <String, dynamic>{
        'recorded_at': '2026-11-17T20:00:30Z',
        'energy_score': 0.5,
        'traffic_light': 'YELLOW',
      },
      <String, dynamic>{
        'recorded_at': '2026-11-17T20:01:00Z',
        'energy_score': energy,
        'traffic_light': light,
      },
    ],
  };
}

final MonitorSession pairedSession = MonitorSession(
  token: 'monitor-token',
  sessionId: 'session-1',
  experienceTitle: 'Noche de Jazz',
  expiresAt: DateTime.utc(2030),
);

/// Sink falso que registra lo enviado y el código de cierre.
class FakeSink implements WebSocketSink {
  final List<dynamic> sent = <dynamic>[];
  int? closedWith;

  @override
  void add(dynamic data) => sent.add(data);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closedWith = closeCode;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Canal WebSocket falso controlado por la prueba.
class FakeChannel implements WebSocketChannel {
  final StreamController<dynamic> incoming = StreamController<dynamic>();
  final FakeSink fakeSink = FakeSink();
  final Uri uri;
  int? serverCloseCode;

  FakeChannel(this.uri);

  @override
  Stream<dynamic> get stream => incoming.stream;

  @override
  WebSocketSink get sink => fakeSink;

  @override
  int? get closeCode => serverCloseCode;

  /// Simula que el servidor cierra la conexión con [code].
  Future<void> serverClose(int code) async {
    serverCloseCode = code;
    await incoming.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Servicio falso para la prueba de la pantalla.
class FakeTelemetryService extends LiveTelemetryService {
  final StreamController<TelemetryEvent> events =
      StreamController<TelemetryEvent>();
  String? redeemedCode;

  @override
  Future<MonitorSession> redeemCode(String code) async {
    redeemedCode = code;
    if (code == 'BAD000') {
      throw const ApiException('Código inválido o vencido.');
    }
    return pairedSession;
  }

  @override
  Stream<TelemetryEvent> watch(MonitorSession session) => events.stream;
}

void main() {
  setUp(() => HttpClient.setAuthToken(null));

  test('interpreta la instantánea del backend', () {
    final LiveTelemetrySnapshot snapshot = LiveTelemetrySnapshot.fromJson(
      snapshotJson(light: 'RED', energy: 0.21, status: 'STALE'),
    );
    expect(snapshot.trafficLight, EnergyTrafficLight.red);
    expect(snapshot.signalStatus, TelemetrySignalStatus.stale);
    expect(snapshot.trend, EnergyTrend.rising);
    expect(snapshot.pulse.length, 2);
    expect(snapshot.detectedFacesCount, 14);
  });

  test('sin métricas el semáforo queda vacío', () {
    final Map<String, dynamic> json = snapshotJson()
      ..['traffic_light'] = null
      ..['energy_score'] = null
      ..['signal_status'] = 'NO_SIGNAL';
    final LiveTelemetrySnapshot snapshot = LiveTelemetrySnapshot.fromJson(json);
    expect(snapshot.trafficLight, isNull);
    expect(snapshot.energyScore, isNull);
    expect(snapshot.signalStatus, TelemetrySignalStatus.noSignal);
  });

  test(
    'canjea el código normalizado sin usar la sesión de asistente',
    () async {
      late Map<String, dynamic> body;
      final MockClient client = MockClient((http.Request request) async {
        expect(request.url.path, endsWith('/live/telemetry/monitor/redeem'));
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode(<String, dynamic>{
            'access_token': 'monitor-token',
            'token_type': 'monitor',
            'session_id': 'session-1',
            'experience_title': 'Noche de Jazz',
            'expires_at': '2030-01-01T00:00:00Z',
          }),
          200,
        );
      });
      final LiveTelemetryService service = LiveTelemetryService(
        httpClient: HttpClient(client: client),
      );
      final MonitorSession session = await service.redeemCode(' k7p 2qx ');
      expect(body['code'], 'K7P2QX');
      expect(session.token, 'monitor-token');
      expect(HttpClient.authToken, isNull);
    },
  );

  test('construye la URL del WebSocket con el token de monitor', () {
    final Uri uri = LiveTelemetryService().buildStreamUri(pairedSession);
    expect(uri.scheme, startsWith('ws'));
    expect(uri.path, endsWith('/live/telemetry/ws/session-1'));
    expect(uri.queryParameters['token'], 'monitor-token');
  });

  test(
    'emite conexión e instantáneas e ignora mensajes que no son telemetría',
    () async {
      final List<FakeChannel> channels = <FakeChannel>[];
      final LiveTelemetryService service = LiveTelemetryService(
        channelFactory: (Uri uri) {
          final FakeChannel channel = FakeChannel(uri);
          channels.add(channel);
          return channel;
        },
      );
      final List<TelemetryEvent> events = <TelemetryEvent>[];
      final StreamSubscription<TelemetryEvent> sub = service
          .watch(pairedSession)
          .listen(events.add);
      await Future<void>.delayed(Duration.zero);

      channels.single.incoming.add(
        jsonEncode(<String, String>{'type': 'pong'}),
      );
      channels.single.incoming.add('no-es-json');
      channels.single.incoming.add(jsonEncode(snapshotJson()));
      await Future<void>.delayed(Duration.zero);

      expect(events.first.connection, TelemetryConnectionState.connecting);
      expect(events[1].connection, TelemetryConnectionState.open);
      expect(events.where((TelemetryEvent e) => e.snapshot != null).length, 1);

      await sub.cancel();
      expect(channels.single.fakeSink.closedWith, 1000);
    },
  );

  test('termina con error si el servidor rechaza la vinculación', () async {
    final List<FakeChannel> channels = <FakeChannel>[];
    final LiveTelemetryService service = LiveTelemetryService(
      channelFactory: (Uri uri) {
        final FakeChannel channel = FakeChannel(uri);
        channels.add(channel);
        return channel;
      },
    );
    final Completer<Object> failure = Completer<Object>();
    service.watch(pairedSession).listen((_) {}, onError: failure.complete);
    await Future<void>.delayed(Duration.zero);
    await channels.single.serverClose(4403);

    final Object error = await failure.future;
    expect(error, isA<TelemetryDeniedException>());
    expect((error as TelemetryDeniedException).closeCode, 4403);
    expect(channels.length, 1);
  });

  test('la espera de reconexión crece y tiene máximo', () {
    final LiveTelemetryService service = LiveTelemetryService();
    expect(service.reconnectDelay(1), const Duration(seconds: 1));
    expect(service.reconnectDelay(3), const Duration(seconds: 4));
    expect(service.reconnectDelay(20), const Duration(seconds: 15));
  });

  test('proyecta el pulso dentro de la ventana de 60 s', () {
    final List<Offset> points = projectPulse(
      LiveTelemetrySnapshot.fromJson(snapshotJson(energy: 1)).pulse,
      DateTime.utc(2026, 11, 17, 20, 1),
      const Size(300, 100),
    );
    expect(points, const <Offset>[Offset(150, 50), Offset(300, 0)]);
  });

  testWidgets('vincula con código y muestra el semáforo', (
    WidgetTester tester,
  ) async {
    final FakeTelemetryService service = FakeTelemetryService();
    await tester.pumpWidget(
      MaterialApp(
        home: LiveMonitorScreen(languageCode: 'es', service: service),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('monitor-code-field')),
      'k7p2qx',
    );
    await tester.tap(find.byKey(const Key('pair-button')));
    await tester.pumpAndSettle();
    expect(service.redeemedCode, 'K7P2QX');
    expect(find.text('Noche de Jazz'), findsOneWidget);

    service.events.add(
      const TelemetryEvent.connection(TelemetryConnectionState.open),
    );
    service.events.add(
      TelemetryEvent.snapshot(LiveTelemetrySnapshot.fromJson(snapshotJson())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Energía alta'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('En vivo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('unpair-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('monitor-code-field')), findsOneWidget);
  });

  testWidgets('muestra el error de un código inválido', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LiveMonitorScreen(
          languageCode: 'es',
          service: FakeTelemetryService(),
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('monitor-code-field')),
      'BAD000',
    );
    await tester.tap(find.byKey(const Key('pair-button')));
    await tester.pumpAndSettle();
    expect(find.text('Código inválido o vencido.'), findsOneWidget);
  });
}
