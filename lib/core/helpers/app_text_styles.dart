import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle h1 = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle h2 = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle h3 = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text
  static TextStyle bodyLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Button Text
  static TextStyle buttonLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static TextStyle buttonMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Category Text
  static TextStyle categoryTitle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Search Bar Text
  static TextStyle searchHint = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Implementation Steps
  static TextStyle stepEnglish = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle stepRational = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
