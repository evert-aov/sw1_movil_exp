import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema tipográfico editorial de EXPERIENCIAS (`Playfair Display` + `Manrope`).
///
/// - **Serif Literaria (`editorial`)**: Títulos principales, nombres de experiencias,
///   encabezados de sección, precios destacados y monograma de marca.
/// - **Sans-serif Geométrica (`sans`)**: Cuerpo de texto, formularios, metadatos y botones.
/// - **Eyebrow (`eyebrow`)**: Etiquetas superiores en mayúsculas con tracking amplio.
class AppTypography {
  const AppTypography._();

  static const List<String> _serifFallback = <String>[
    'Georgia',
    'Cambria',
    'Times New Roman',
    'serif',
  ];

  static const List<String> _sansFallback = <String>[
    'Roboto',
    'Helvetica Neue',
    'sans-serif',
  ];

  /// Tipografía serif literaria (*Playfair Display*) para títulos y marca.
  static TextStyle editorial({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    ).copyWith(fontFamilyFallback: _serifFallback);
  }

  /// Tipografía sans-serif geométrica (*Manrope*) para lectura, UI y controles.
  static TextStyle sans({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    ).copyWith(fontFamilyFallback: _sansFallback);
  }

  /// Etiqueta superior (*Eyebrow / Kicker*) en mayúsculas con tracking amplio.
  static TextStyle eyebrow(bool isDark, {double fontSize = 11}) {
    return sans(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.0,
      color: AppColors.accent(isDark),
    );
  }
}

/// Monograma editorial de marca ("E" en Playfair Display sobre terracota),
/// replicando el encabezado oficial de la plataforma web.
class EditorialBrandMark extends StatelessWidget {
  final double size;

  const EditorialBrandMark({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent(isDark),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        'E',
        style: AppTypography.editorial(
          fontSize: size * 0.62,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}
