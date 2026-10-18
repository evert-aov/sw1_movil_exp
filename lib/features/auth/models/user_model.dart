/// Modelo de dominio que representa al Usuario Asistente dentro de la aplicación móvil (CU-02 / HU-03).
///
/// Cumple con el principio de responsabilidad única representando exclusivamente
/// la entidad de perfil y preferencias del asistente sin valores predefinidos harcodeados.
class UserModel {
  /// Identificador único del asistente.
  final int id;

  /// Nombre de pila del asistente.
  final String firstName;

  /// Apellido del asistente.
  final String? lastName;

  /// Correo electrónico registrado.
  final String email;

  /// Número de teléfono móvil de contacto.
  final String? phone;

  /// Ciudad de residencia para filtrado por proximidad geográfica.
  final String city;

  /// Barrio o zona frecuente del asistente.
  final String zone;

  /// Biografía corta del asistente.
  final String bio;

  /// URL opcional de imagen de avatar.
  final String? avatarUrl;

  /// Lista de etiquetas de intereses temáticos del asistente.
  final List<String> interests;

  /// Construye una instancia inmutable de [UserModel].
  const UserModel({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.city = '',
    this.zone = '',
    this.bio = '',
    this.avatarUrl,
    this.interests = const <String>[],
  });

  /// Retorna el nombre completo concatenando [firstName] y [lastName].
  String get fullName {
    if (lastName == null || lastName!.trim().isEmpty) {
      return firstName;
    }
    return '$firstName $lastName';
  }

  /// Crea una copia de [UserModel] con los campos modificados especificados.
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? city,
    String? zone,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      zone: zone ?? this.zone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      interests: interests ?? List<String>.from(this.interests),
    );
  }

  /// Construye una instancia de [UserModel] a partir de un mapa JSON proveniente de la API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      city: json['city'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      interests: List<String>.from(
        json['interests'] as Iterable? ?? const <String>[],
      ),
    );
  }

  /// Serializa esta instancia de [UserModel] a un mapa JSON para envío por red.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'city': city,
      'zone': zone,
      'bio': bio,
      'avatar_url': avatarUrl,
      'interests': interests,
    };
  }
}
