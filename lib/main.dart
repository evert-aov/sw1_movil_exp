import 'package:flutter/material.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/experience/screens/catalog_screen.dart';

/// Punto de entrada principal multiplataforma de EXPERIENCIA (Android, iOS, Web, Windows, macOS, Linux).
void main() {
  runApp(const ExperienciaApp());
}

/// Widget raíz que coordina el estado global de Tema (Claro/Oscuro), Idioma (ES/EN)
/// y navegación adaptativa del Sprint 1 para todas las plataformas.
class ExperienciaApp extends StatefulWidget {
  /// Crea la instancia raíz de [ExperienciaApp].
  const ExperienciaApp({super.key});

  @override
  State<ExperienciaApp> createState() => _ExperienciaAppState();
}

class _ExperienciaAppState extends State<ExperienciaApp> {
  final ThemeController _themeController = ThemeController();
  final LocaleController _localeController = LocaleController();

  @override
  void dispose() {
    _themeController.dispose();
    _localeController.dispose();
    super.dispose();
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
          home: MainNavigationScreen(
            i18n: i18n,
            onToggleTheme: _themeController.toggleTheme,
            onToggleLanguage: _localeController.toggleLocale,
          ),
        );
      },
    );
  }
}

/// Estructura de navegación adaptativa multiplataforma para el Sprint 1:
/// - En pantallas móviles/compactas muestra `NavigationBar` inferior.
/// - En pantallas anchas (Web, Tablet, Desktop) adapta el contenedor y navegación.
class MainNavigationScreen extends StatefulWidget {
  /// Diccionario de localización activo.
  final AppLocalizations i18n;

  /// Acción para alternar entre tema claro y oscuro.
  final VoidCallback onToggleTheme;

  /// Acción para alternar entre Español e Inglés.
  final VoidCallback onToggleLanguage;

  /// Crea una instancia de [MainNavigationScreen].
  const MainNavigationScreen({
    super.key,
    required this.i18n,
    required this.onToggleTheme,
    required this.onToggleLanguage,
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
      LoginScreen(
        i18n: i18n,
        onToggleTheme: widget.onToggleTheme,
        onToggleLanguage: widget.onToggleLanguage,
        onAuthenticated: (_) {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
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
            onLogout: () {
              setState(() {
                _currentIndex = 0;
              });
            },
            onToggleTheme: widget.onToggleTheme,
            onToggleLanguage: widget.onToggleLanguage,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryViolet,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    i18n.tr('app_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    i18n.tr('app_subtitle'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
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
            icon: const Icon(
              Icons.translate_rounded,
              size: 16,
              color: AppColors.primaryVioletLight,
            ),
            label: Text(
              i18n.languageCode.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: AppColors.primaryVioletLight,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: isDark ? i18n.tr('theme_light') : i18n.tr('theme_dark'),
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.lock_open_outlined),
            selectedIcon: const Icon(
              Icons.lock_open_rounded,
              color: AppColors.primaryVioletLight,
            ),
            label: i18n.tr('tab_login'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(
              Icons.explore,
              color: AppColors.primaryVioletLight,
            ),
            label: i18n.tr('nav_discover'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryVioletLight,
            ),
            label: i18n.tr('nav_profile'),
          ),
        ],
      ),
    );
  }
}
