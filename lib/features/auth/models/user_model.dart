// Modelo de usuario para la aplicación móvil
class UserModel {
  final int id;
  final String firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final List<String> interests;

  UserModel({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.interests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}
