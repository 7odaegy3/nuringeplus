import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../data/models/onboarding_page_model.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageModel page;

  const OnboardingPageContent({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Container(
              width: 300.w,
              height: 300.h,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Image.asset(page.imagePath, fit: BoxFit.contain),
            ),
            SizedBox(height: 40.h),
            Text(
              page.title,
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              page.description,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
