import '../models/live_telemetry_model.dart';

/// Recuerda en memoria el monitor vinculado mientras la app sigue abierta (HU-17 / HU-18).
///
/// Permite salir de la pantalla del monitor con "atrás" y volver sin ingresar otro código.
/// La vinculación solo se pierde al pulsar "Desvincular", al vencer el token o al cerrar la app;
/// mientras tanto el celular sigue registrado para las alertas push del Asistente MC.
class MonitorSessionStore {
  MonitorSessionStore._();

  static MonitorSession? _current;

  /// Vinculación vigente, o null si no hay ninguna o ya venció.
  static MonitorSession? get current {
    final MonitorSession? session = _current;
    if (session == null || session.isExpired) return null;
    return session;
  }

  /// Guarda la vinculación recién canjeada.
  static void save(MonitorSession session) => _current = session;

  /// Olvida la vinculación (al desvincular).
  static void clear() => _current = null;
}
