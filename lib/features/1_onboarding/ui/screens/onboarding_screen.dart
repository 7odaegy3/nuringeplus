import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'مرحباً بك في نيرسنج بلس',
      'description':
          'تطبيق شامل يساعدك في تعلم وتطبيق الإجراءات التمريضية بشكل صحيح وآمن.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'خطوات مفصلة وواضحة',
      'description':
          'شرح تفصيلي لكل إجراء مع توضيح الأسباب العلمية وراء كل خطوة.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'احفظ تقدمك وتعلم في أي وقت',
      'description':
          'يمكنك حفظ الإجراءات المفضلة وتتبع تقدمك في التعلم بسهولة.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      AppRouter.goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageContent(data: _pages[index]);
            },
          ),
          Positioned(
            top: 60.h,
            left: 20.w,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'تخطي',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 8.h,
                      width: _currentPage == index ? 24.w : 8.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                if (_currentPage == _pages.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56.h),
                      ),
                      child: Text(
                        'ابدأ الآن',
                        style: AppTextStyles.buttonLarge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
