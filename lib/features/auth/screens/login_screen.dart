import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../live/live_monitor_strings.dart';
import '../../live/screens/live_monitor_screen.dart';
import '../models/auth_credentials_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

/// Pantalla de Inicio de Sesión y Registro multiplataforma para el Usuario Asistente (Sprint 1 • CU-01 / CU-02).
///
/// Se adapta automáticamente tanto a pantallas móviles (Android / iOS) como a pantallas
/// anchas (Web / Desktop / Tablet) mostrando el diseño dividido de dos columnas
/// de las capturas oficiales sin datos harcodeados.
class LoginScreen extends StatefulWidget {
  /// Diccionario de localización activo.
  final AppLocalizations i18n;

  /// Callback ejecutado cuando el asistente inicia sesión exitosamente en el servidor.
  final ValueChanged<UserModel> onAuthenticated;

  /// Callback para alternar entre tema claro y oscuro.
  final VoidCallback onToggleTheme;

  /// Callback para alternar el idioma entre Español e Inglés.
  final VoidCallback onToggleLanguage;

  /// Crea una instancia de [LoginScreen].
  const LoginScreen({
    super.key,
    required this.i18n,
    required this.onAuthenticated,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _showRegisterTab = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Procesa el envío de credenciales hacia [AuthService.login] sin datos harcodeados.
  Future<void> _onLoginSubmitted() async {
    setState(() => _errorMessage = null);

    final credentials = AuthCredentialsModel(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!credentials.isValid) {
      setState(() {
        _errorMessage = widget.i18n.tr('validation_error');
      });
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final UserModel user = await _authService.login(credentials);
      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onAuthenticated(user);
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppLocalizations i18n = widget.i18n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const EditorialBrandMark(size: 34),
            const SizedBox(width: 11),
            Text(
              i18n.tr('app_title'),
              style: AppTypography.editorial(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                fontSize: 18,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          // HU-17: acceso del anfitrión al monitor en vivo sin iniciar sesión de asistente
          IconButton(
            key: const Key('live-monitor-entry'),
            tooltip: LiveMonitorStrings(i18n.languageCode).tr('entry'),
            icon: Icon(
              Icons.monitor_heart_outlined,
              size: 20,
              color: AppColors.textPrimary(isDark),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    LiveMonitorScreen(languageCode: i18n.languageCode),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: widget.onToggleLanguage,
            icon: Icon(
              Icons.translate_rounded,
              size: 16,
              color: AppColors.accent(isDark),
            ),
            label: Text(
              i18n.languageCode.toUpperCase(),
              style: AppTypography.sans(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.8,
                color: AppColors.accent(isDark),
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: isDark ? i18n.tr('theme_light') : i18n.tr('theme_dark'),
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >= 880;
            if (isWide) {
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: 11,
                    child: Container(
                      height: double.infinity,
                      color: AppColors.surfaceSoft(isDark),
                      child: _buildHeroBrandingPanel(context),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.border(isDark),
                  ),
                  Expanded(
                    flex: 10,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _buildAuthFormPanel(context),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildAuthFormPanel(context),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye el panel izquierdo de presentación visual para pantallas anchas (Web/Desktop/Tablet).
  Widget _buildHeroBrandingPanel(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppLocalizations i18n = widget.i18n;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            i18n.tr('hero_tagline').toUpperCase(),
            style: AppTypography.eyebrow(isDark),
          ),
          const SizedBox(height: 22),
          Text(
            i18n.tr('hero_title'),
            style: AppTypography.editorial(
              fontSize: 42,
              fontWeight: FontWeight.w500,
              height: 1.12,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              i18n.tr('hero_description'),
              style: AppTypography.sans(
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildFeatureHighlightCard(
                  context: context,
                  icon: Icons.groups_outlined,
                  title: i18n.tr('feature_1_title'),
                  description: i18n.tr('feature_1_desc'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureHighlightCard(
                  context: context,
                  icon: Icons.verified_user_outlined,
                  title: i18n.tr('feature_2_title'),
                  description: i18n.tr('feature_2_desc'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureHighlightCard(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  title: i18n.tr('feature_3_title'),
                  description: i18n.tr('feature_3_desc'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta informativa con icono para la columna de presentación.
  Widget _buildFeatureHighlightCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
        boxShadow: AppColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentSoft(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.accent(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.sans(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTypography.sans(
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el panel del formulario de Inicio de Sesión / Registro.
  Widget _buildAuthFormPanel(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppLocalizations i18n = widget.i18n;
    final Color accent = AppColors.accent(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            i18n.tr('welcome_badge').toUpperCase(),
            style: AppTypography.eyebrow(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            _showRegisterTab
                ? i18n.tr('register_header')
                : i18n.tr('login_header'),
            style: AppTypography.editorial(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            i18n.tr('auth_subtitle'),
            style: AppTypography.sans(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary(isDark),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          // Selector segmentado: Iniciar sesión / Crear cuenta
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _showRegisterTab = false;
                      _errorMessage = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: !_showRegisterTab ? accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        i18n.tr('tab_login'),
                        style: AppTypography.sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: !_showRegisterTab
                              ? Colors.white
                              : AppColors.textSecondary(isDark),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _showRegisterTab = true;
                      _errorMessage = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _showRegisterTab ? accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        i18n.tr('tab_register'),
                        style: AppTypography.sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _showRegisterTab
                              ? Colors.white
                              : AppColors.textSecondary(isDark),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          if (_errorMessage != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerBg(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.roseDanger.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.dangerText(isDark),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: AppColors.dangerText(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_showRegisterTab)
            RegisterScreen(
              i18n: i18n,
              onRegistered: widget.onAuthenticated,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  i18n.tr('label_email'),
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: i18n.tr('hint_email'),
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      size: 19,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  i18n.tr('label_password'),
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: i18n.tr('hint_password'),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 19,
                    ),
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
                        color: accent,
                      ),
                      label: Text(
                        _obscurePassword
                            ? i18n.tr('show_password')
                            : i18n.tr('hide_password'),
                        style: AppTypography.sans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Tarjeta de rol Asistente
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.person_outline_rounded,
                        color: accent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              i18n.tr('attendee_role_title'),
                              style: AppTypography.sans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              i18n.tr('attendee_role_desc'),
                              style: AppTypography.sans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle_rounded,
                        color: accent,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _onLoginSubmitted,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                      i18n.tr('btn_login'),
                      style: AppTypography.sans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                Center(
                  child: Text(
                    i18n.tr('terms_footer'),
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
