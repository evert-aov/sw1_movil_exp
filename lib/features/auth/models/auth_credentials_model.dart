/// Modelo de transferencia de datos (DTO) para credenciales de autenticación (CU-01).
///
/// Aísla en un archivo independiente los datos de inicio de sesión y registro
/// del asistente móvil para evitar sobrecargar el modelo de perfil.
class AuthCredentialsModel {
  /// Correo electrónico del asistente.
  final String email;

  /// Contraseña en texto plano para validación de acceso.
  final String password;

  /// Nombre completo opcional utilizado únicamente durante el registro (HU-01).
  final String? fullName;

  /// Crea una instancia de [AuthCredentialsModel].
  const AuthCredentialsModel({
    required this.email,
    required this.password,
    this.fullName,
  });

  /// Valida si las credenciales cumplen con el formato mínimo requerido.
  bool get isValid => email.contains('@') && password.trim().length >= 6;

  /// Convierte las credenciales a formato JSON para peticiones de autenticación.
  Map<String, dynamic> toJson() {
    String? firstName;
    String? lastName;
    if (fullName != null && fullName!.trim().isNotEmpty) {
      final parts = fullName!.trim().split(RegExp(r'\s+'));
      firstName = parts.first;
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    return <String, dynamic>{
      'email': email.trim(),
      'password': password,
      if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
      if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
      'role': 'ATTENDEE',
    };
  }
}
