import 'package:flutter/material.dart';

/// Controlador reactivo encargado de gestionar el estado del tema visual (Claro / Oscuro).
///
/// Aplica el principio de responsabilidad única administrando exclusivamente
/// la preferencia de [ThemeMode] en toda la aplicación.
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  /// Obtiene el modo de tema activo actualmente.
  ThemeMode get themeMode => _themeMode;

  /// Indica si el modo oscuro se encuentra activo actualmente.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Alterna entre el tema claro ([ThemeMode.light]) y el tema oscuro ([ThemeMode.dark]).
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Establece explícitamente el [mode] de tema deseado y notifica a los oyentes.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}
