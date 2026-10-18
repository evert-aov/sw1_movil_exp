import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_client.dart';
import '../models/auth_credentials_model.dart';
import '../models/user_model.dart';

/// Servicio de dominio encargado de la autenticación y perfil del Usuario Asistente (CU-01, CU-02).
///
/// Diseñado con bajo acoplamiento mediante inyección de [HttpClient] y sin datos
/// harcodeados: toda la identidad y perfil provienen de las respuestas del servidor API.
class AuthService {
  final HttpClient _httpClient;

  /// Usuario asistente autenticado en la sesión actual, obtenido desde el backend.
  static UserModel? _currentUser;

  /// Crea una instancia de [AuthService] recibiendo opcionalmente un [HttpClient].
  AuthService({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  /// Retorna el perfil en caché de la sesión activa o `null` si no ha iniciado sesión.
  UserModel? get currentUser => _currentUser;

  /// Indica si existe una sesión autenticada activa.
  bool get isAuthenticated =>
      _currentUser != null || HttpClient.authToken != null;

  /// Autentica a un asistente en el backend mediante sus [credentials] de acceso (CU-01 / HU-02).
  ///
  /// Extrae el token JWT si es devuelto por la API y carga el [UserModel] correspondiente.
  Future<UserModel> login(AuthCredentialsModel credentials) async {
    final dynamic response = await _httpClient.post(
      ApiConstants.loginEndpoint,
      credentials.toJson(),
    );

    if (response is Map<String, dynamic>) {
      final String? token = (response['access_token'] ??
          response['token'] ??
          response['jwt']) as String?;
      if (token != null) {
        HttpClient.setAuthToken(token);
      }

      if (response['user'] is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(
          response['user'] as Map<String, dynamic>,
        );
        return _currentUser!;
      }

      if (response.containsKey('email') || response.containsKey('first_name')) {
        _currentUser = UserModel.fromJson(response);
        return _currentUser!;
      }
    }

    return fetchProfile();
  }

  /// Registra una nueva cuenta de Usuario Asistente en el backend (CU-01 / HU-01).
  ///
  /// Envía [credentials] al endpoint de registro y retorna el [UserModel] creado por el servidor.
  Future<UserModel> register(AuthCredentialsModel credentials) async {
    final dynamic response = await _httpClient.post(
      ApiConstants.registerEndpoint,
      credentials.toJson(),
    );

    if (response is Map<String, dynamic>) {
      final String? token = (response['access_token'] ??
          response['token'] ??
          response['jwt']) as String?;
      if (token != null) {
        HttpClient.setAuthToken(token);
      } else {
        // El endpoint /auth/register del backend retorna ProfileDTO sin token JWT.
        // Se realiza login automático con las credenciales para adquirir el JWT y abrir la sesión.
        try {
          return await login(credentials);
        } catch (_) {
          // Si el login falla, conserva el perfil retornado por el registro.
        }
      }

      if (response['user'] is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(
          response['user'] as Map<String, dynamic>,
        );
        return _currentUser!;
      }

      _currentUser = UserModel.fromJson(response);
      return _currentUser!;
    }

    return fetchProfile();
  }

  /// Consulta los datos actualizados del perfil del asistente desde el servidor (`GET /users/me`).
  Future<UserModel> fetchProfile() async {
    final dynamic response = await _httpClient.get(
      ApiConstants.profileEndpoint,
    );
    if (response is Map<String, dynamic>) {
      final Map<String, dynamic> data =
          response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response;
      _currentUser = UserModel.fromJson(data);
      return _currentUser!;
    }
    throw const ApiException('Formato de perfil inválido recibido del servidor.');
  }

  /// Actualiza los datos personales, ubicación, biografía e intereses en el backend (CU-02 / HU-03).
  ///
  /// Envía [updatedUser] mediante `PUT /users/me` y retorna la entidad confirmada por el servidor.
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    final dynamic response = await _httpClient.put(
      ApiConstants.profileEndpoint,
      updatedUser.toUpdateJson(),
    );

    if (response is Map<String, dynamic>) {
      final Map<String, dynamic> data =
          response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response;
      _currentUser = UserModel.fromJson(data);
      return _currentUser!;
    }

    _currentUser = updatedUser;
    return _currentUser!;
  }

  /// Cierra la sesión actual limpiando el token JWT y la referencia del usuario en memoria.
  void logout() {
    HttpClient.setAuthToken(null);
    _currentUser = null;
  }
}
