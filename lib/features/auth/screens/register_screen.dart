import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../models/auth_credentials_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Formulario cohesivo de Registro de Cuenta para Usuario Asistente (Sprint 1 • CU-01 / HU-01).
///
/// Mantiene responsabilidad única gestionando el alta de un nuevo asistente móvil
/// validando estrictamente los campos ingresados sin valores por defecto harcodeados.
class RegisterScreen extends StatefulWidget {
  /// Diccionario de localización activo (Español / Inglés).
  final AppLocalizations i18n;

  /// Callback invocado tras completar el registro del asistente en el servidor.
  final ValueChanged<UserModel> onRegistered;

  /// Crea una instancia de [RegisterScreen].
  const RegisterScreen({
    super.key,
    required this.i18n,
    required this.onRegistered,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Ejecuta el registro de la nueva cuenta en [AuthService.register] validando la entrada real.
  Future<void> _onRegisterSubmitted() async {
    setState(() => _errorMessage = null);

    final String fullName = _fullNameController.text.trim();
    final credentials = AuthCredentialsModel(
      fullName: fullName,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (fullName.isEmpty || !credentials.isValid) {
      setState(() {
        _errorMessage = widget.i18n.tr('validation_register_error');
      });
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final UserModel newUser = await _authService.register(credentials);
      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onRegistered(newUser);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = '${widget.i18n.tr('api_error_prefix')} ${e.message}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = widget.i18n;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_errorMessage != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.roseDanger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.roseDanger.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.error_outline_rounded,
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
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],

        Text(
          i18n.tr('label_fullname'),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            hintText: i18n.tr('hint_fullname'),
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 19),
          ),
        ),
        const SizedBox(height: 15),

        Text(
          i18n.tr('label_email'),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: i18n.tr('hint_email'),
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 19),
          ),
        ),
        const SizedBox(height: 15),

        Text(
          i18n.tr('label_password'),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: i18n.tr('hint_password'),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
            suffixIcon: TextButton.icon(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 16,
                color: AppColors.primaryVioletLight,
              ),
              label: Text(
                _obscurePassword
                    ? i18n.tr('show_password')
                    : i18n.tr('hide_password'),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryVioletLight,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Tarjeta de Rol Asistente Móvil
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryVioletLight, width: 1.5),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.explore_outlined,
                color: AppColors.primaryVioletLight,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      i18n.tr('attendee_role_title'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      i18n.tr('attendee_role_desc'),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryVioletLight,
                size: 20,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _onRegisterSubmitted,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryViolet,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(
              i18n.tr('btn_register'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),
        Center(
          child: Text(
            i18n.tr('terms_footer'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
