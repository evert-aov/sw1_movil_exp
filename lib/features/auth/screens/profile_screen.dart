import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Pantalla de Gestión de Perfil y Preferencias del Asistente (Sprint 1 • CU-02 / CU-03 / HU-03).
///
/// Obtiene y actualiza dinámicamente los datos del perfil en el servidor mediante [AuthService],
/// sin emplear nombres, ciudades ni intereses harcodeados.
class ProfileScreen extends StatefulWidget {
  /// Diccionario de localización activo (Español / Inglés).
  final AppLocalizations i18n;

  /// Callback para cerrar la sesión actual.
  final VoidCallback onLogout;

  /// Callback para alternar entre tema claro y oscuro.
  final VoidCallback onToggleTheme;

  /// Callback para alternar entre Español e Inglés.
  final VoidCallback onToggleLanguage;

  /// Crea una instancia de [ProfileScreen].
  const ProfileScreen({
    super.key,
    required this.i18n,
    required this.onLogout,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _customInterestController =
      TextEditingController();

  UserModel? _user;
  List<String> _selectedInterests = <String>[];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _zoneController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _customInterestController.dispose();
    super.dispose();
  }

  /// Carga los datos reales del asistente desde [AuthService.fetchProfile].
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final UserModel? cached = _authService.currentUser;
    if (cached != null) {
      _populateControllers(cached);
    }

    try {
      final UserModel remoteUser = await _authService.fetchProfile();
      if (mounted) {
        setState(() {
          _populateControllers(remoteUser);
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${widget.i18n.tr('api_error_prefix')} ${e.message}';
        });
      }
    }
  }

  /// Sincroniza los controladores de texto con los campos de la entidad [user].
  void _populateControllers(UserModel user) {
    _user = user;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName ?? '';
    _cityController.text = user.city;
    _zoneController.text = user.zone;
    _phoneController.text = user.phone ?? '';
    _emailController.text = user.email;
    _bioController.text = user.bio;
    _selectedInterests = List<String>.from(user.interests);
  }

  /// Elimina o alterna un interés [interest] de la lista del asistente.
  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  /// Agrega un nuevo interés escrito por el asistente en el campo de texto.
  void _addCustomInterest() {
    final String value = _customInterestController.text.trim();
    if (value.isEmpty) return;
    if (!_selectedInterests.contains(value)) {
      setState(() {
        _selectedInterests.add(value);
      });
    }
    _customInterestController.clear();
  }

  /// Envía los datos actualizados del formulario a [AuthService.updateProfile] (CU-02 / HU-03).
  Future<void> _onSaveProfilePressed() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final UserModel baseUser = _user ??
        const UserModel(
          id: '',
          firstName: '',
          email: '',
        );

    final UserModel updated = baseUser.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      city: _cityController.text.trim(),
      zone: _zoneController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      interests: _selectedInterests,
    );

    try {
      final UserModel saved = await _authService.updateProfile(updated);
      if (mounted) {
        setState(() {
          _user = saved;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.emeraldSuccess,
            content: Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.i18n.tr('profile_saved_toast'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = '${widget.i18n.tr('api_error_prefix')} ${e.message}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = widget.i18n;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryViolet),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        if (_errorMessage != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.roseDanger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.roseDanger.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.roseDanger,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.roseDanger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadProfile,
                  tooltip: i18n.tr('btn_retry'),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.roseDanger,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Formulario principal de Perfil sin valores harcodeados
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Fila Nombre y Apellido
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildLabeledField(
                      label: i18n.tr('label_firstname'),
                      controller: _firstNameController,
                      hint: i18n.tr('hint_firstname'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLabeledField(
                      label: i18n.tr('label_lastname'),
                      controller: _lastNameController,
                      hint: i18n.tr('hint_lastname'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fila Ciudad y Barrio / Zona
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildLabeledField(
                      label: i18n.tr('label_city'),
                      controller: _cityController,
                      hint: i18n.tr('hint_city'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLabeledField(
                      label: i18n.tr('label_zone'),
                      controller: _zoneController,
                      hint: i18n.tr('hint_zone'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fila Teléfono y Correo electrónico
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildLabeledField(
                      label: i18n.tr('label_phone'),
                      controller: _phoneController,
                      hint: i18n.tr('hint_phone'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLabeledField(
                      label: i18n.tr('label_email'),
                      controller: _emailController,
                      hint: i18n.tr('hint_email'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Biografía
              Text(
                i18n.tr('label_bio'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: i18n.tr('hint_bio'),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1),
              ),

              // Sección Intereses y preferencias dinámicos
              Text(
                i18n.tr('interests_title'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                i18n.tr('interests_subtitle'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),

              if (_selectedInterests.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    i18n.tr('interests_empty'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedInterests.map((String item) {
                    return GestureDetector(
                      onTap: () => _toggleInterest(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryViolet.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryVioletLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              item,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primaryViolet,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.primaryVioletLight,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 14),

              // Campo para agregar nuevo interés
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _customInterestController,
                      onSubmitted: (_) => _addCustomInterest(),
                      decoration: InputDecoration(
                        hintText: i18n.tr('hint_add_interest'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addCustomInterest,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryViolet,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Botón Guardar cambios y Cerrar sesión
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () {
                      _authService.logout();
                      widget.onLogout();
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 17,
                      color: AppColors.roseDanger,
                    ),
                    label: Text(
                      i18n.tr('btn_logout'),
                      style: const TextStyle(
                        color: AppColors.roseDanger,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _onSaveProfilePressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryViolet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      i18n.tr('btn_save_changes'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye un campo de formulario con su etiqueta superior correspondiente.
  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
