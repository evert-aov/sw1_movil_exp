/// Constantes de configuración de red y rutas de la API REST para el asistente móvil.
///
/// Cumple con el principio de responsabilidad única centralizando únicamente
/// las rutas de acceso remoto del cliente móvil y permitiendo inyectar la URL
/// base por variables de entorno en tiempo de compilación (`--dart-define`).
class ApiConstants {
  /// Constructor privado para evitar instanciación de clase utilitaria.
  const ApiConstants._();

  /// URL base del servidor backend obtenida por configuración de entorno.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

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
