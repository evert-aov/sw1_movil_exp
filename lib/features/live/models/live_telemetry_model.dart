/// Color del semáforo discreto de energía de la audiencia (HU-17).
enum EnergyTrafficLight {
  /// Energía alta.
  green,

  /// Energía media.
  yellow,

  /// Energía baja.
  red;

  /// Convierte el valor del backend (`GREEN`, `YELLOW`, `RED`) o devuelve null.
  static EnergyTrafficLight? fromApi(Object? value) {
    switch (value) {
      case 'GREEN':
        return EnergyTrafficLight.green;
      case 'YELLOW':
        return EnergyTrafficLight.yellow;
      case 'RED':
        return EnergyTrafficLight.red;
    }
    return null;
  }
}

/// Dirección reciente del índice de energía (HU-17).
enum EnergyTrend {
  /// La energía sube.
  rising,

  /// La energía se mantiene.
  stable,

  /// La energía baja.
  falling;

  /// Convierte el valor del backend; cualquier valor desconocido se trata como estable.
  static EnergyTrend fromApi(Object? value) {
    switch (value) {
      case 'RISING':
        return EnergyTrend.rising;
      case 'FALLING':
        return EnergyTrend.falling;
    }
    return EnergyTrend.stable;
  }
}

/// Estado de la señal de métricas de la sesión (HU-17).
enum TelemetrySignalStatus {
  /// Métrica de los últimos 7.5 s.
  live,

  /// Última métrica de hasta 30 s.
  stale,

  /// Sin métricas recientes.
  noSignal;

  /// Convierte el valor del backend (`LIVE`, `STALE`, `NO_SIGNAL`).
  static TelemetrySignalStatus fromApi(Object? value) {
    switch (value) {
      case 'LIVE':
        return TelemetrySignalStatus.live;
      case 'STALE':
        return TelemetrySignalStatus.stale;
    }
    return TelemetrySignalStatus.noSignal;
  }
}

/// Punto de la gráfica de pulso de energía.
class PulsePoint {
  /// Instante de la métrica en UTC.
  final DateTime recordedAt;

  /// Índice de energía suavizado de 0 a 1.
  final double energyScore;

  /// Crea un punto de pulso.
  const PulsePoint({required this.recordedAt, required this.energyScore});

  /// Construye el punto desde el JSON del backend.
  factory PulsePoint.fromJson(Map<String, dynamic> json) {
    return PulsePoint(
      recordedAt: DateTime.parse(json['recorded_at'] as String).toUtc(),
      energyScore: (json['energy_score'] as num).toDouble(),
    );
  }
}

/// Instantánea de telemetría agregada emitida cada 2.5 s (solo promedios anónimos, GDPR).
class LiveTelemetrySnapshot {
  /// ID de la sesión en vivo.
  final String sessionId;

  /// Instante de emisión en UTC.
  final DateTime emittedAt;

  /// Estado de la señal.
  final TelemetrySignalStatus signalStatus;

  /// Índice de energía suavizado; null si nunca hubo métricas.
  final double? energyScore;

  /// Color del semáforo; null si nunca hubo métricas.
  final EnergyTrafficLight? trafficLight;

  /// Tendencia reciente.
  final EnergyTrend trend;

  /// Rostros detectados en la última métrica.
  final int? detectedFacesCount;

  /// Últimos 60 s de energía.
  final List<PulsePoint> pulse;

  /// Crea una instantánea.
  const LiveTelemetrySnapshot({
    required this.sessionId,
    required this.emittedAt,
    required this.signalStatus,
    required this.energyScore,
    required this.trafficLight,
    required this.trend,
    required this.detectedFacesCount,
    required this.pulse,
  });

  /// Construye la instantánea desde el JSON del canal WebSocket.
  factory LiveTelemetrySnapshot.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPulse =
        json['pulse'] as List<dynamic>? ?? <dynamic>[];
    return LiveTelemetrySnapshot(
      sessionId: json['session_id'] as String,
      emittedAt: DateTime.parse(json['emitted_at'] as String).toUtc(),
      signalStatus: TelemetrySignalStatus.fromApi(json['signal_status']),
      energyScore: (json['energy_score'] as num?)?.toDouble(),
      trafficLight: EnergyTrafficLight.fromApi(json['traffic_light']),
      trend: EnergyTrend.fromApi(json['trend']),
      detectedFacesCount: json['detected_faces_count'] as int?,
      pulse: rawPulse
          .whereType<Map<String, dynamic>>()
          .map(PulsePoint.fromJson)
          .toList(growable: false),
    );
  }
}

/// Vinculación del dispositivo como monitor de una sesión (resultado de canjear el código).
class MonitorSession {
  /// Token de monitor de solo lectura (no sirve para otros endpoints).
  final String token;

  /// ID de la sesión en vivo vinculada.
  final String sessionId;

  /// Título de la experiencia transmitida.
  final String experienceTitle;

  /// Expiración del token en UTC.
  final DateTime expiresAt;

  /// Crea una vinculación.
  const MonitorSession({
    required this.token,
    required this.sessionId,
    required this.experienceTitle,
    required this.expiresAt,
  });

  /// Construye la vinculación desde la respuesta de canje.
  factory MonitorSession.fromJson(Map<String, dynamic> json) {
    return MonitorSession(
      token: json['access_token'] as String,
      sessionId: json['session_id'] as String,
      experienceTitle: json['experience_title'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
    );
  }

  /// Indica si el token ya venció.
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
}
