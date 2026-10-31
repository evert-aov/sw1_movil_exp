import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../experience/services/experience_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Pantalla de Gestión de Perfil y Preferencias del Asistente (Sprint 1 • CU-02 / CU-03 / HU-03).
///
/// Obtiene y actualiza dinámicamente los datos del perfil en el servidor mediante [AuthService],
/// permitiendo seleccionar intereses estandarizados con un solo toque para un matching óptimo.
class ProfileScreen extends StatefulWidget {
  /// Diccionario de localización activo (Español / Inglés).
  final AppLocalizations i18n;

  /// Callback para cerrar la sesión actual.
  final Future<void> Function() onLogout;

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
  final ExperienceService _experienceService = ExperienceService();

  static const List<String> _defaultTopics = <String>[
    'Gastronomía',
    'Café de especialidad',
    'Cata y Maridaje',
    'Arte y Pintura',
    'Música y Conciertos',
    'Música en vivo',
    'DJ y Electrónica',
    'Talleres y Educación',
    'Tecnología y Software',
    'Networking y Negocios',
    'Bienestar y Outdoors',
    'Yoga y Mindfulness',
    'Diseño UI/UX',
    'Fotografía',
  ];

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
  List<String> _backendCategories = <String>[];
  List<String> _availableTopics = List<String>.from(_defaultTopics);
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCategories();
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

  /// Sincroniza la lista unificada de temas para selección rápida
  void _syncAvailableTopics() {
    final Set<String> all = <String>{
      ..._defaultTopics,
      ..._backendCategories.where((String c) => c.isNotEmpty && c != 'Todos'),
      ..._selectedInterests,
    };
    _availableTopics = all.toList();
  }

  /// Carga dinámicamente las categorías temáticas desde el servidor
  Future<void> _loadCategories() async {
    try {
      final List<Map<String, dynamic>> raw =
          await _experienceService.getCategories();
      if (mounted) {
        final List<String> names = raw
            .map((Map<String, dynamic> item) => item['name']?.toString() ?? '')
            .where((String name) => name.trim().isNotEmpty)
            .toList();
        setState(() {
          _backendCategories = names;
          _syncAvailableTopics();
        });
      }
    } catch (_) {
      // Si la carga remota falla se mantienen los temas por defecto
    }
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
    _syncAvailableTopics();
  }

  /// Elimina o alterna un interés [interest] de la lista del asistente.
  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
      _syncAvailableTopics();
    });
  }

  /// Agrega un nuevo interés escrito por el asistente en el campo de texto.
  void _addCustomInterest() {
    final String value = _customInterestController.text.trim();
    if (value.isEmpty) return;
    if (!_selectedInterests.contains(value)) {
      setState(() {
        _selectedInterests.add(value);
        _syncAvailableTopics();
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

    final UserModel baseUser =
        _user ?? const UserModel(id: '', firstName: '', email: '');

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
                decoration: InputDecoration(hintText: i18n.tr('hint_bio')),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1),
              ),

              // Sección Intereses y preferencias estandarizados para matching
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    i18n.tr('interests_title'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_selectedInterests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryViolet.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedInterests.length} activos',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryViolet,
                        ),
                      ),
                    ),
                ],
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
              const SizedBox(height: 14),

              // Chips de temas disponibles (por defecto + categorías backend + intereses activos)
              // Al tocarlos se agregan o quitan al instante sin necesidad de escribir texto directamente.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTopics.map((String topic) {
                  final bool isSelected = _selectedInterests.contains(topic);
                  return FilterChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (_) => _toggleInterest(topic),
                    selectedColor: AppColors.primaryViolet,
                    checkmarkColor: Colors.white,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceElevated
                        : Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryViolet
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                    showCheckmark: true,
                    avatar: isSelected
                        ? null
                        : const Icon(
                            Icons.add_rounded,
                            size: 15,
                            color: AppColors.primaryViolet,
                          ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Campo secundario opcional para agregar un interés personalizado
              Text(
                i18n.tr('interests_custom_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _customInterestController,
                      onSubmitted: (_) => _addCustomInterest(),
                      decoration: InputDecoration(
                        hintText: i18n.tr('hint_add_custom_interest'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addCustomInterest,
                    tooltip: i18n.tr('hint_add_interest'),
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
                    onPressed: widget.onLogout,
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
