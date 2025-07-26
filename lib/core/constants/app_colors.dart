import 'package:flutter/material.dart';

class AppColors {
  // Colores principales del diseño Pet Shop
  static const Color primary = Color(0xFF1a237e); // Azul navy
  static const Color secondary = Color(0xFFdb682d); // Naranja específico
  static const Color accent = Color(0xFF7b1fa2); // Morado

  // Colores complementarios
  static const Color orange = Color(0xFFff9800); // Naranja
  static const Color darkBlue = Color(0xFF0d47a1); // Azul más oscuro
  static const Color lightPurple = Color(0xFF9c27b0); // Morado claro

  // Gradientes para formas orgánicas
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1a237e), Color(0xFF3949ab)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7b1fa2), Color(0xFF9c27b0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFff9800), Color(0xFFffb74d)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Colores base
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF424242);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color success = Color(0xFFA5D6A7);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE57373);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Colores con opacidad para formas decorativas
  static const Color purpleOverlay = Color(0x4D7b1fa2);
  static const Color orangeOverlay = Color(0x33ff9800);
  static const Color yellowOverlay = Color(0x66ffc107);
}
