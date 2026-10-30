import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_client.dart';
import '../models/auth_credentials_model.dart';
import '../models/user_model.dart';

/// La sesión móvil requiere ATTENDEE explícito y se confirma con el perfil del servidor.
class AuthService {
  final HttpClient _httpClient;
  static UserModel? _currentUser;
  AuthService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated =>
      _currentUser?.canUseMobile == true && HttpClient.authToken != null;

  void clearSession() {
    HttpClient.setAuthToken(null);
    _currentUser = null;
  }

  UserModel _acceptProfile(UserModel user) {
    if (!user.canUseMobile) {
      clearSession();
      throw const ApiException(
        'La app móvil requiere el rol ATTENDEE. Usa la web para gestionar tu cuenta de anfitrión o administrador.',
        statusCode: 403,
      );
    }
    _currentUser = user;
    return user;
  }

  Future<UserModel> login(AuthCredentialsModel credentials) async {
    clearSession();
    try {
      final response = await _httpClient.post(
        ApiConstants.loginEndpoint,
        credentials.toJson(),
      );
      if (response is! Map<String, dynamic> ||
          response['access_token'] is! String ||
          (response['access_token'] as String).isEmpty) {
        throw const ApiException('No se recibió una sesión válida.');
      }
      HttpClient.setAuthToken(response['access_token'] as String);
      // El token no sustituye al perfil ni a sus roles actuales.
      return await fetchProfile();
    } catch (_) {
      clearSession();
      rethrow;
    }
  }

  Future<UserModel> register(AuthCredentialsModel credentials) async {
    await _httpClient.post(ApiConstants.registerEndpoint, {
      ...credentials.toJson(),
      'role': 'ATTENDEE',
    });
    return login(credentials);
  }

  Future<UserModel> fetchProfile() async {
    try {
      final response = await _httpClient.get(ApiConstants.profileEndpoint);
      if (response is! Map<String, dynamic>) {
        throw const ApiException(
          'Formato de perfil inválido recibido del servidor.',
        );
      }
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return _acceptProfile(UserModel.fromJson(data));
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) clearSession();
      rethrow;
    }
  }

  Future<UserModel> updateProfile(UserModel updatedUser) async {
    final response = await _httpClient.put(
      ApiConstants.profileEndpoint,
      updatedUser.toUpdateJson(),
    );
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        'Formato de perfil inválido recibido del servidor.',
      );
    }
    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    return _acceptProfile(UserModel.fromJson(data));
  }

  Future<bool> logout() async {
    try {
      if (HttpClient.authToken != null) {
        await _httpClient
            .post(ApiConstants.logoutEndpoint, <String, dynamic>{})
            .timeout(const Duration(seconds: 5));
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      clearSession();
    }
  }
}
