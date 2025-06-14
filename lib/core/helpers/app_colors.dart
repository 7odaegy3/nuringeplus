import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF6A11CB);
  static const primaryLight = Color(0xFF8833FF);
  static const primaryDark = Color(0xFF4A0C8F);

  // Secondary Colors
  static const secondary = Color(0xFF2575FC);
  static const secondaryLight = Color(0xFF4A8FFF);
  static const secondaryDark = Color(0xFF1A52B2);

  // Accent Colors
  static const accent1 = Color(0xFF00B4DB);
  static const accent2 = Color(0xFFFF416C);
  static const accent3 = Color(0xFFFFB300);

  // Light Theme Colors
  static const lightBackground = Color(0xFFF8F9FA);
  static const lightSurface = Colors.white;
  static const lightCard = Colors.white;
  static const lightDivider = Color(0xFFE9ECEF);
  static const lightText = Color(0xFF212529);
  static const lightTextSecondary = Color(0xFF6C757D);
  static const lightTextDisabled = Color(0xFFADB5BD);

  // Dark Theme Colors
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkCard = Color(0xFF2C2C2C);
  static const darkDivider = Color(0xFF323232);
  static const darkText = Color(0xFFF8F9FA);
  static const darkTextSecondary = Color(0xFFADB5BD);
  static const darkTextDisabled = Color(0xFF6C757D);

  // Status Colors
  static const success = Color(0xFF28A745);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFDC3545);
  static const info = Color(0xFF17A2B8);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient1 = LinearGradient(
    colors: [accent1, Color(0xFF0083B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient2 = LinearGradient(
    colors: [accent2, Color(0xFFFF4B2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> getLightShadow({
    double opacity = 0.1,
    double blurRadius = 10,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  static List<BoxShadow> getDarkShadow({
    double opacity = 0.3,
    double blurRadius = 10,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }
}
