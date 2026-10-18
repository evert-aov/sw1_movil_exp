import 'package:flutter/material.dart';

/// Paleta cromática oficial de EXPERIENCIA para modo claro y modo oscuro.
///
/// Mantiene alta cohesión aislando todas las constantes de color de la lógica
/// de construcción de widgets o temas.
class AppColors {
  const AppColors._();

  // Acentos principales de marca (Violeta eléctrico inspirado en el diseño oficial)
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color primaryVioletLight = Color(0xFF8B5CF6);
  static const Color primaryVioletSoft = Color(0xFFEDE9FE);

  // Colores semánticos de estado (Quórum y Confirmaciones)
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color emeraldBgLight = Color(0xFFECFDF5);
  static const Color emeraldBgDark = Color(0xFF062E22);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color amberBgLight = Color(0xFFFFFBEB);
  static const Color amberBgDark = Color(0xFF2E2006);
  static const Color roseDanger = Color(0xFFF43F5E);

  // Superficies Modo Oscuro (Obsidian Dark)
  static const Color darkBackground = Color(0xFF09090F);
  static const Color darkSurface = Color(0xFF12121C);
  static const Color darkSurfaceElevated = Color(0xFF1A1A27);
  static const Color darkBorder = Color(0xFF262638);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Superficies Modo Claro (Alabaster Light)
  static const Color lightBackground = Color(0xFFF5F4FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1EFFA);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
}
