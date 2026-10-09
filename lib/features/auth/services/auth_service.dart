import '../models/user_model.dart';

// Servicio de autenticación: únicamente firmas de métodos (CU-01, CU-02)
class AuthService {
  Future<String?> login(String email, String password) async {
    // Firma para autenticación y obtención de JWT
    return null;
  }

  Future<UserModel?> register(String firstName, String email, String password) async {
    // Firma para registro de nuevo usuario
    return null;
  }

  Future<UserModel?> getProfile() async {
    // Firma para obtener información del usuario
    return null;
  }

  Future<void> logout() async {
    // Firma para limpiar token y cerrar sesión
  }
}
