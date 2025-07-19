import 'package:flutter/material.dart';

class AppColors {
  // Colores principales - Inspirados en el diseño moderno
  static const Color primary = Color(0xFF0D47A1); // Azul profundo moderno
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0A3D91);

  static const Color secondary = Color(0xFF00BCD4); // Cyan vibrante
  static const Color secondaryLight = Color(0xFF26C6DA);
  static const Color secondaryDark = Color(0xFF00ACC1);

  static const Color accent = Color(0xFFFF6B35); // Naranja energético
  static const Color accentLight = Color(0xFFFF8A50);
  static const Color accentDark = Color(0xFFE64100);

  // Fondos oscuros modernos
  static const Color backgroundDark = Color(
    0xFF0A0E13,
  ); // Negro azulado profundo
  static const Color backgroundDarkSecondary = Color(
    0xFF1A1F29,
  ); // Gris oscuro azulado
  static const Color backgroundDarkCard = Color(0xFF252B37); // Tarjetas oscuras

  // Fondos claros
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundLightSecondary = Color(0xFFF1F5F9);
  static const Color backgroundLightCard = Color(0xFFFFFFFF);

  // Textos
  static const Color textPrimary = Color(0xFF0F172A); // Texto principal oscuro
  static const Color textSecondary = Color(0xFF475569); // Texto secundario
  static const Color textTertiary = Color(0xFF94A3B8); // Texto terciario

  static const Color textPrimaryDark = Color(
    0xFFF8FAFC,
  ); // Texto principal en modo oscuro
  static const Color textSecondaryDark = Color(
    0xFFCBD5E1,
  ); // Texto secundario en modo oscuro
  static const Color textTertiaryDark = Color(
    0xFF64748B,
  ); // Texto terciario en modo oscuro

  // Estados
  static const Color success = Color(0xFF10B981); // Verde éxito
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B); // Amarillo advertencia
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444); // Rojo error
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6); // Azul información
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Grises modernos
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundDark, backgroundDarkSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Colores específicos para VetZoone
  static const Color vetPrimary = Color(
    0xFF1E3A8A,
  ); // Azul veterinario profesional
  static const Color vetSecondary = Color(0xFF059669); // Verde salud
  static const Color vetAccent = Color(0xFFF59E0B); // Amarillo atención

  // Sombras
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> floatingActionButtonShadow = [
    BoxShadow(color: Color(0x26000000), blurRadius: 12, offset: Offset(0, 6)),
  ];
}
