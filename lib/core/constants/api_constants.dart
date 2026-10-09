// Constantes de conexión API para la aplicación móvil
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Emulador Android o localhost
  
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/users/me';
  
  static const String experiencesEndpoint = '/experiences/catalog';
  static const String bookingsEndpoint = '/bookings';
  static const String myTicketsEndpoint = '/bookings/my-tickets';
  static const String matchingEndpoint = '/matching';
}
