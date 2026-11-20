import 'package:flutter/material.dart';

/// Paleta cromática oficial del Sistema de Diseño Editorial de EXPERIENCIAS
/// para modo claro y modo oscuro, alineada 1:1 con `DESIGN_SYSTEM.md` y `styles.css`.
///
/// Tonos tierra cálidos: papel crema, arena, café tostado, roble oscuro y terracota.
class AppColors {
  const AppColors._();

  // =========================================================================
  // PALETA CLARA (:root) — Papel crema, arena, marrón oscuro y terracota
  // =========================================================================
  static const Color lightBackground = Color(0xFFFBF8F3); // --ui-surface
  static const Color lightSurface = Color(0xFFFBF8F3); // --ui-surface
  static const Color lightCard = Color(0xFFFFFFFF); // Tarjeta limpia sobre crema
  static const Color lightSurfaceSoft = Color(0xFFF2EBE0); // --ui-surface-soft
  static const Color lightSurfaceElevated = Color(0xFFF2EBE0); // alias
  static const Color lightBorder = Color(0xFFE3D8CC); // --ui-border
  static const Color lightTextPrimary = Color(0xFF281E19); // --ui-text
  static const Color lightTextSecondary = Color(0xFF78695D); // --ui-muted
  static const Color lightAccent = Color(0xFFBE5338); // --ui-accent
  static const Color lightAccentHover = Color(0xFF9E3F27); // --ui-accent-hover
  static const Color lightAccentSoft = Color(0xFFF6ECE4); // --ui-accent-soft

  // =========================================================================
  // PALETA OSCURA (:root.dark) — Noche cálida, roble tostado y ámbar arcilla
  // =========================================================================
  static const Color darkBackground = Color(0xFF191411); // --ui-surface
  static const Color darkSurface = Color(0xFF191411); // --ui-surface
  static const Color darkCard = Color(0xFF201A15); // Tarjeta sutil sobre roble
  static const Color darkSurfaceSoft = Color(0xFF251E18); // --ui-surface-soft
  static const Color darkSurfaceElevated = Color(0xFF251E18); // alias
  static const Color darkBorder = Color(0xFF3A3028); // --ui-border
  static const Color darkTextPrimary = Color(0xFFF3EBE2); // --ui-text
  static const Color darkTextSecondary = Color(0xFFA39487); // --ui-muted
  static const Color darkAccent = Color(0xFFE27A5D); // --ui-accent
  static const Color darkAccentHover = Color(0xFFEC8D72); // --ui-accent-hover
  static const Color darkAccentSoft = Color(0xFF35231A); // --ui-accent-soft

  // =========================================================================
  // COLORES SEMÁNTICOS DE ESTADO (Quórum, Confirmaciones, Alertas)
  // =========================================================================
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color emeraldTextLight = Color(0xFF047857);
  static const Color emeraldTextDark = Color(0xFF6EE7B7);
  static const Color emeraldBgLight = Color(0xFFECFDF5);
  static const Color emeraldBgDark = Color(0xFF062E22);

  static const Color amberWarning = Color(0xFFD97706);
  static const Color amberTextLight = Color(0xFF92400E);
  static const Color amberTextDark = Color(0xFFFCD34D);
  static const Color amberBgLight = Color(0xFFFFFBEB);
  static const Color amberBgDark = Color(0xFF2E2006);

  static const Color roseDanger = Color(0xFFDC2626);
  static const Color dangerTextLight = Color(0xFFB91C1C);
  static const Color dangerTextDark = Color(0xFFFCA5A5);
  static const Color dangerBgLight = Color(0xFFFEF2F2);
  static const Color dangerBgDark = Color(0xFF331414);

  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBgLight = Color(0xFFEFF6FF);
  static const Color infoBgDark = Color(0xFF122338);

  // =========================================================================
  // HELPERS DINÁMICOS POR TEMA
  // =========================================================================
  static Color accent(bool isDark) => isDark ? darkAccent : lightAccent;
  static Color accentHover(bool isDark) =>
      isDark ? darkAccentHover : lightAccentHover;
  static Color accentSoft(bool isDark) =>
      isDark ? darkAccentSoft : lightAccentSoft;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceSoft(bool isDark) =>
      isDark ? darkSurfaceSoft : lightSurfaceSoft;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color dangerText(bool isDark) =>
      isDark ? dangerTextDark : dangerTextLight;
  static Color dangerBg(bool isDark) => isDark ? dangerBgDark : dangerBgLight;

  /// Sombra cálida editorial (solo en modo claro, como `.ui-surface` en web).
  static List<BoxShadow>? cardShadow(bool isDark) {
    if (isDark) return null;
    return <BoxShadow>[
      BoxShadow(
        color: lightTextPrimary.withValues(alpha: 0.045),
        blurRadius: 18,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
