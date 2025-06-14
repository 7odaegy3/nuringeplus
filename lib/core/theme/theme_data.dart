import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      iconTheme: const IconThemeData(color: AppColors.lightText),
      titleTextStyle: const TextStyle(
        color: AppColors.lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      displayMedium:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      displaySmall:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      headlineLarge:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      headlineMedium:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      headlineSmall:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      titleLarge:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      titleMedium:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      titleSmall:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      bodyLarge: TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      bodyMedium: TextStyle(
          fontFamily: 'ReadexPro', color: AppColors.lightTextSecondary),
      bodySmall: TextStyle(
          fontFamily: 'ReadexPro', color: AppColors.lightTextDisabled),
      labelLarge:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.lightText),
      labelMedium: TextStyle(
          fontFamily: 'ReadexPro', color: AppColors.lightTextSecondary),
      labelSmall: TextStyle(
          fontFamily: 'ReadexPro', color: AppColors.lightTextDisabled),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.lightText,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.lightTextDisabled;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withOpacity(0.5);
        }
        return AppColors.lightDivider;
      }),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      iconTheme: const IconThemeData(color: AppColors.darkText),
      titleTextStyle: const TextStyle(
        color: AppColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      displayMedium:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      displaySmall:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      headlineLarge:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      headlineMedium:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      headlineSmall:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      titleLarge: TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      titleMedium:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      titleSmall: TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      bodyLarge: TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      bodyMedium: TextStyle(
          fontFamily: 'ReadexPro', color: AppColors.darkTextSecondary),
      bodySmall:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkTextDisabled),
      labelLarge: TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkText),
      labelMedium: TextStyle(
          fontFamily: 'ReadexPro', color: AppColors.darkTextSecondary),
      labelSmall:
          TextStyle(fontFamily: 'ReadexPro', color: AppColors.darkTextDisabled),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.darkText,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.darkTextDisabled;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withOpacity(0.5);
        }
        return AppColors.darkDivider;
      }),
    ),
  );
}
