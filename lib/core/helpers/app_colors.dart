import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Category Card Colors
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF9C27B0), Color(0xFF7B1FA2)], // Purple
    [Color(0xFF2196F3), Color(0xFF1976D2)], // Blue
    [Color(0xFF4CAF50), Color(0xFF388E3C)], // Green
    [Color(0xFFF44336), Color(0xFFD32F2F)], // Red
  ];

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);

  // Icon Colors
  static const Color iconActive = Color(0xFF2196F3);
  static const Color iconInactive = Color(0xFF9E9E9E);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);

  // Saved Procedures Colors
  static const Color savedGradientStart = Color(0xFFE3F2FD);
  static const Color savedGradientEnd = Color(0xFFBBDEFB);
}
