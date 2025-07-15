import 'package:flutter/material.dart';

/// Sistema de colores para MagicScan inspirado en Magic: The Gathering
class AppColors {
  // Colores primarios - Azul mágico
  static const Color primary = Color(0xFF2E7DD2);
  static const Color primaryLight = Color(0xFF5BA3F5);
  static const Color primaryDark = Color(0xFF1A5A9F);

  // Colores secundarios - Púrpura místico
  static const Color secondary = Color(0xFF8B5FBF);
  static const Color secondaryLight = Color(0xFFB085E8);
  static const Color secondaryDark = Color(0xFF6B4C93);

  // Colores de superficie
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  // Colores de texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Colores de acento - Rareza de cartas MTG
  static const Color rare = Color(0xFFFFD700); // Dorado - Rare
  static const Color mythic = Color(0xFFFF6B35); // Naranja - Mythic Rare
  static const Color uncommon = Color(0xFFC0C0C0); // Plata - Uncommon
  static const Color common = Color(0xFF8B4513); // Marrón - Common

  // Estados
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FA), Color(0xFFE5E7EB)],
  );

  // Glassmorphism - Efecto cristal estilo Apple
  static const Color glassBackground = Color(0xFFF8F9FA);
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0xFFE5E7EB);

  // Gradientes glassmorphism
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF), // Blanco puro
      Color(0xFFF8F9FA), // Blanco grisáceo
    ],
  );

  static const LinearGradient glassBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF1F5F9), // Gris azulado claro
      Color(0xFFE2E8F0), // Gris azulado medio
    ],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEFF6FF), // Azul muy claro
      Color(0xFFF8FAFC), // Gris muy claro
    ],
  );
}
