import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 120.w,
              height: 120.w,
            ),
            SizedBox(height: 24.h),
            // App Name
            Text(
              'Nursing Plus',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 32.sp,
              ),
            ),
            SizedBox(height: 8.h),
            // Arabic App Name
            Text(
              'نيرسنج بلس',
              style: AppTextStyles.h2.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 48.h),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
