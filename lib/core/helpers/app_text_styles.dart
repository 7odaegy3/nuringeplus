import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle h1 = GoogleFonts.cairo(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.lightText,
  );

  static TextStyle h2 = GoogleFonts.cairo(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.lightText,
  );

  static TextStyle h3 = GoogleFonts.cairo(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.lightText,
  );

  // Body Text
  static TextStyle bodyLarge = GoogleFonts.cairo(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.lightText,
  );

  static TextStyle bodyMedium = GoogleFonts.cairo(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.lightText,
  );

  static TextStyle bodySmall = GoogleFonts.cairo(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextSecondary,
  );

  // Button Text
  static TextStyle buttonLarge = GoogleFonts.cairo(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle buttonMedium = GoogleFonts.cairo(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Implementation Steps (English)
  static TextStyle implementationStep = GoogleFonts.roboto(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.lightText,
  );

  // Labels and Captions
  static TextStyle label = GoogleFonts.cairo(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextSecondary,
  );

  static TextStyle caption = GoogleFonts.cairo(
    fontSize: 10.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextDisabled,
  );

  // Get theme-aware text style
  static TextStyle getThemedStyle(TextStyle style, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = style.color;

    if (color == AppColors.lightText) {
      return style.copyWith(
          color: isDark ? AppColors.darkText : AppColors.lightText);
    } else if (color == AppColors.lightTextSecondary) {
      return style.copyWith(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary);
    } else if (color == AppColors.lightTextDisabled) {
      return style.copyWith(
          color: isDark
              ? AppColors.darkTextDisabled
              : AppColors.lightTextDisabled);
    }

    return style;
  }
}
