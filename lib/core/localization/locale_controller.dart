import 'package:flutter/material.dart';

/// Controlador reactivo encargado exclusivamente de gestionar el idioma activo de la app.
///
/// Soporta Español ('es') e Inglés ('en') con cambio en tiempo real y bajo acoplamiento.
class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('es');

  /// Obtiene la configuración regional ([Locale]) activa actualmente.
  Locale get locale => _locale;

  /// Indica si el idioma activo es Español.
  bool get isSpanish => _locale.languageCode == 'es';

  /// Alterna entre Español ('es') e Inglés ('en').
  void toggleLocale() {
    _locale = isSpanish ? const Locale('en') : const Locale('es');
    notifyListeners();
  }

  /// Define explícitamente el código de idioma [languageCode] ('es' o 'en').
  void setLanguage(String languageCode) {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}
