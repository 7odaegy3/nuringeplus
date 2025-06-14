import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_text_styles.dart';

class OnboardingPageContent extends StatelessWidget {
  final Map<String, String> data;

  const OnboardingPageContent({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // خلفية متدرجة جميلة
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFF3EFFF),
                Color(0xFFE9F0FF),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // دائرة شفافة خلف الصورة
              Container(
                height: 220.h,
                width: 220.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      data['image']!,
                      height: 160.h,
                      width: 160.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48.h),
              // Title
              Text(
                data['title']!,
                style: AppTextStyles.h1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B2EFF),
                  shadows: [
                    Shadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Description
              Text(
                data['description']!,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.black87,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
