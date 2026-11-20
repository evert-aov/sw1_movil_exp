import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_client.dart';
import '../../../core/services/push_notification_service.dart';
import '../models/live_telemetry_model.dart';

/// Fábrica de canales WebSocket inyectable para pruebas.
typedef TelemetryChannelFactory = WebSocketChannel Function(Uri uri);

/// Estado de la conexión con el canal de telemetría.
enum TelemetryConnectionState {
  /// Primer intento de conexión.
  connecting,

  /// Conectado y recibiendo instantáneas.
  open,

  /// Conexión perdida; reintentando.
  reconnecting,
}

/// Evento del flujo de telemetría: cambio de conexión o nueva instantánea.
class TelemetryEvent {
  /// Nuevo estado de conexión, si el evento es de conexión.
  final TelemetryConnectionState? connection;

  /// Nueva instantánea, si el evento es de datos.
  final LiveTelemetrySnapshot? snapshot;

  const TelemetryEvent._({this.connection, this.snapshot});

  /// Crea un evento de cambio de conexión.
  const TelemetryEvent.connection(TelemetryConnectionState state)
    : this._(connection: state);

  /// Crea un evento con una instantánea.
  const TelemetryEvent.snapshot(LiveTelemetrySnapshot data)
    : this._(snapshot: data);
}

/// Error emitido cuando el servidor rechaza la vinculación (código 4401, 4403 o 4404).
class TelemetryDeniedException implements Exception {
  /// Código de cierre WebSocket recibido.
  final int closeCode;

  /// Crea la excepción con el [closeCode] del servidor.
  const TelemetryDeniedException(this.closeCode);

  @override
  String toString() => 'TelemetryDeniedException($closeCode)';
}

/// Servicio del Monitor de Telemetría en Vivo para tablets y celulares (HU-17).
///
/// Canjea el código mostrado en la consola web por un token de monitor de solo lectura y
/// se suscribe al canal WebSocket que emite el semáforo de energía cada 2.5 s.
/// No usa la sesión de asistente: el token de monitor se guarda solo en memoria de la vista.
class LiveTelemetryService {
  /// Endpoint de canje del código de vinculación.
  static const String redeemEndpoint = '/live/telemetry/monitor/redeem';

  /// Códigos de cierre con los que el backend rechaza la conexión de forma definitiva.
  static const Set<int> denialCloseCodes = <int>{4401, 4403, 4404};

  /// Espera máxima entre reintentos.
  static const Duration maxReconnectDelay = Duration(seconds: 15);

  /// Intervalo del latido que mantiene viva la conexión.
  static const Duration heartbeatInterval = Duration(seconds: 25);

  final HttpClient _http;
  final TelemetryChannelFactory _channelFactory;

  /// Crea el servicio permitiendo inyectar el cliente HTTP y la fábrica de WebSocket.
  LiveTelemetryService({
    HttpClient? httpClient,
    TelemetryChannelFactory? channelFactory,
  }) : _http = httpClient ?? HttpClient(),
       _channelFactory = channelFactory ?? WebSocketChannel.connect;

  /// Canjea el [code] de la consola web por una vinculación de monitor.
  ///
  /// Lanza [ApiException] si el código es inválido, ya se usó, venció o hubo demasiados intentos.
  Future<MonitorSession> redeemCode(String code) async {
    final String normalized = code.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final dynamic response = await _http.post(redeemEndpoint, <String, dynamic>{
      'code': normalized,
    });
    final MonitorSession session = MonitorSession.fromJson(
      response as Map<String, dynamic>,
    );
    unawaited(
      PushNotificationService.instance.registerForMonitorSession(
        monitorToken: session.token,
      ),
    );
    return session;
  }

  /// Construye la URL `ws://` o `wss://` del canal de telemetría de la [session].
  Uri buildStreamUri(MonitorSession session) {
    final String wsBase = ApiConstants.baseUrl.replaceFirst(
      RegExp(r'^http'),
      'ws',
    );
    return Uri.parse(
      '$wsBase/live/telemetry/ws/${Uri.encodeComponent(session.sessionId)}',
    ).replace(queryParameters: <String, String>{'token': session.token});
  }

  /// Calcula la espera antes del reintento número [attempt] (exponencial con máximo).
  Duration reconnectDelay(int attempt) {
    final int millis = 1000 * (1 << (attempt - 1).clamp(0, 10));
    return millis > maxReconnectDelay.inMilliseconds
        ? maxReconnectDelay
        : Duration(milliseconds: millis);
  }

  /// Abre el canal de telemetría y emite el estado de conexión y cada instantánea.
  ///
  /// Reintenta con espera exponencial si la conexión se corta; si el servidor rechaza la
  /// vinculación, el flujo termina con [TelemetryDeniedException]. Cancelar la suscripción
  /// cierra el WebSocket.
  Stream<TelemetryEvent> watch(MonitorSession session) {
    late final StreamController<TelemetryEvent> controller;
    WebSocketChannel? channel;
    StreamSubscription<dynamic>? subscription;
    Timer? reconnectTimer;
    Timer? heartbeatTimer;
    int attempt = 0;
    bool stopped = false;

    void clearTimers() {
      reconnectTimer?.cancel();
      heartbeatTimer?.cancel();
    }

    late void Function() connect;

    void handleClosed() {
      clearTimers();
      if (stopped) return;
      final int? code = channel?.closeCode;
      if (code != null && denialCloseCodes.contains(code)) {
        controller.addError(TelemetryDeniedException(code));
        controller.close();
        return;
      }
      attempt += 1;
      controller.add(
        const TelemetryEvent.connection(TelemetryConnectionState.reconnecting),
      );
      reconnectTimer = Timer(reconnectDelay(attempt), connect);
    }

    connect = () {
      if (stopped) return;
      controller.add(
        TelemetryEvent.connection(
          attempt == 0
              ? TelemetryConnectionState.connecting
              : TelemetryConnectionState.reconnecting,
        ),
      );
      final WebSocketChannel current = _channelFactory(buildStreamUri(session));
      channel = current;
      bool opened = false;
      subscription = current.stream.listen(
        (dynamic message) {
          if (!opened) {
            opened = true;
            attempt = 0;
            controller.add(
              const TelemetryEvent.connection(TelemetryConnectionState.open),
            );
            heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
              current.sink.add(jsonEncode(<String, String>{'type': 'ping'}));
            });
          }
          final LiveTelemetrySnapshot? snapshot = _parse(message);
          if (snapshot != null) {
            controller.add(TelemetryEvent.snapshot(snapshot));
          }
        },
        onError: (Object _) {},
        onDone: handleClosed,
        cancelOnError: false,
      );
    };

    controller = StreamController<TelemetryEvent>(
      onListen: () => connect(),
      onCancel: () async {
        stopped = true;
        clearTimers();
        await subscription?.cancel();
        await channel?.sink.close(1000);
      },
    );
    return controller.stream;
  }

  /// Interpreta un mensaje y descarta los que no son instantáneas (por ejemplo `pong`).
  LiveTelemetrySnapshot? _parse(dynamic message) {
    if (message is! String) return null;
    try {
      final dynamic decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic> && decoded['type'] == 'telemetry') {
        return LiveTelemetrySnapshot.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
