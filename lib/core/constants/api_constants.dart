import 'package:flutter/foundation.dart';

/// Constantes de configuración de red y rutas de la API REST multiplataforma.
///
/// Cumple con el principio de responsabilidad única centralizando las rutas
/// de acceso remoto y resolviendo automáticamente el host base según la
/// plataforma de ejecución (Android, iOS, Web, Windows, macOS, Linux) sin
/// acoplar paquetes incompatibles con Web.
class ApiConstants {
  /// Constructor privado para evitar instanciación de clase utilitaria.
  const ApiConstants._();

  /// Valor opcional inyectado por compilación mediante `--dart-define=API_BASE_URL=...`.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Retorna la URL base del servidor backend adaptada a la plataforma actual.
  ///
  /// - Si se definió `API_BASE_URL` por entorno, utiliza ese valor.
  /// - En Android nativo utiliza `http://10.0.2.2:8000/api` para conectar con el host.
  /// - En Web, iOS, Windows, macOS y Linux utiliza `http://localhost:8000/api`.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  /// Endpoint para inicio de sesión de asistentes (CU-01 / HU-02).
  static const String loginEndpoint = '/auth/login';

  /// Endpoint para registro de nuevos asistentes (CU-01 / HU-01).
  static const String registerEndpoint = '/auth/register';

  /// Endpoint para consulta y actualización de perfil del asistente (CU-02 / HU-03).
  static const String profileEndpoint = '/users/me';

  /// Endpoint para exploración de catálogo de experiencias (CU-04 / HU-05).
  static const String experiencesEndpoint = '/experiences/catalog';

  /// Endpoint para creación de reservas y pago de cupos (CU-05 / HU-06).
  static const String bookingsEndpoint = '/bookings';

  /// Endpoint para consulta de entradas digitales con código QR (HU-12).
  static const String myTicketsEndpoint = '/bookings/my-tickets';

  /// Endpoint para postulación a grupos de matching dinámico (CU-06 / HU-09).
  static const String matchingEndpoint = '/matching';
}
