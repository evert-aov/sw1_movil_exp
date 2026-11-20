import 'package:flutter/material.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/models/user_model.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/experience/screens/catalog_screen.dart';
import 'features/booking/screens/my_tickets_screen.dart';
import 'features/notifications/notifications_screen.dart';

/// Punto de entrada principal multiplataforma de EXPERIENCIA (Android, iOS, Web, Windows, macOS, Linux).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.instance.initialize();
  runApp(const ExperienciaApp());
}

/// Widget raíz que coordina el estado global de Tema (Claro/Oscuro), Idioma (ES/EN)
/// y flujo de autenticación del Asistente (Login como primera pantalla).
class ExperienciaApp extends StatefulWidget {
  /// Crea la instancia raíz de [ExperienciaApp].
  const ExperienciaApp({super.key});

  @override
  State<ExperienciaApp> createState() => _ExperienciaAppState();
}

class _ExperienciaAppState extends State<ExperienciaApp>
    with WidgetsBindingObserver {
  final ThemeController _themeController = ThemeController();
  final LocaleController _localeController = LocaleController();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentUser = _authService.currentUser?.canUseMobile == true
        ? _authService.currentUser
        : null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeController.dispose();
    _localeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentUser != null) {
      _verifyMobileAccess();
    }
  }

  Future<void> _verifyMobileAccess() async {
    try {
      final user = await _authService.fetchProfile();
      if (mounted) setState(() => _currentUser = user);
    } catch (_) {
      if (!_authService.isAuthenticated && mounted) {
        setState(() => _currentUser = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _themeController,
        _localeController,
      ]),
      builder: (BuildContext context, Widget? _) {
        final AppLocalizations i18n = AppLocalizations(
          _localeController.locale.languageCode,
        );

        return MaterialApp(
          title: i18n.tr('app_title'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          locale: _localeController.locale,
          home: _currentUser == null || !_authService.isAuthenticated
              ? LoginScreen(
                  i18n: i18n,
                  onToggleTheme: _themeController.toggleTheme,
                  onToggleLanguage: _localeController.toggleLocale,
                  onAuthenticated: (UserModel user) {
                    setState(() {
                      _currentUser = user.canUseMobile ? user : null;
                    });
                  },
                )
              : MainNavigationScreen(
                  i18n: i18n,
                  onToggleTheme: _themeController.toggleTheme,
                  onToggleLanguage: _localeController.toggleLocale,
                  onLogout: () async {
                    await _authService.logout();
                    if (!mounted) return;
                    setState(() {
                      _currentUser = null;
                    });
                  },
                ),
        );
      },
    );
  }
}

/// Estructura de navegación principal tras iniciar sesión en el Sprint 1:
/// - En pantallas móviles/compactas muestra `NavigationBar` inferior (Descubrir y Perfil).
/// - En pantallas anchas (Web, Tablet, Desktop) adapta el contenedor y navegación.
class MainNavigationScreen extends StatefulWidget {
  /// Diccionario de localización activo.
  final AppLocalizations i18n;

  /// Acción para alternar entre tema claro y oscuro.
  final VoidCallback onToggleTheme;

  /// Acción para alternar entre Español e Inglés.
  final VoidCallback onToggleLanguage;

  /// Acción para cerrar sesión y volver a la pantalla inicial de Login.
  final Future<void> Function() onLogout;

  /// Crea una instancia de [MainNavigationScreen].
  const MainNavigationScreen({
    super.key,
    required this.i18n,
    required this.onToggleTheme,
    required this.onToggleLanguage,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppLocalizations i18n = widget.i18n;

    final List<Widget> screens = <Widget>[
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: CatalogScreen(i18n: i18n),
        ),
      ),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ProfileScreen(
            i18n: i18n,
            onLogout: widget.onLogout,
            onToggleTheme: widget.onToggleTheme,
            onToggleLanguage: widget.onToggleLanguage,
          ),
        ),
      ),
      MyTicketsScreen(i18n: i18n),
      NotificationsScreen(i18n: i18n),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const EditorialBrandMark(size: 34),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    i18n.tr('app_title'),
                    style: AppTypography.editorial(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      fontSize: 17,
                      color: AppColors.textPrimary(isDark),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    i18n.tr('app_subtitle'),
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      fontSize: 10.5,
                      color: AppColors.textSecondary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
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
          const SizedBox(width: 4),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border(isDark), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: <Widget>[
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: Icon(
                Icons.explore,
                color: AppColors.accent(isDark),
              ),
              label: i18n.tr('nav_discover'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.accent(isDark),
              ),
              label: i18n.tr('nav_profile'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.confirmation_number_outlined),
              selectedIcon: Icon(
                Icons.confirmation_number,
                color: AppColors.accent(isDark),
              ),
              label: i18n.tr('nav_tickets'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_outlined),
              selectedIcon: Icon(
                Icons.notifications,
                color: AppColors.accent(isDark),
              ),
              label: i18n.tr('nav_notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
