import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/api/firebase_service.dart';
import '../../logic/cubit/auth_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(FirebaseService()),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            AppRouter.goToHome(context);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Image.asset(
                      'assets/images/app_logo.png',
                      height: 120.h,
                      width: 120.w,
                    ),
                    SizedBox(height: 48.h),

                    // Welcome Text
                    Text(
                      'مرحباً بك في نيرسنج بلس',
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'سجل دخولك واحفظ تقدمك وبروسيدجراتك المفضلة',
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48.h),

                    // Google Sign In Button
                    ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () => context.read<AuthCubit>().signInWithGoogle(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56.h),
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/google_logo.png',
                                  height: 24.h,
                                  width: 24.w,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'تسجيل الدخول باستخدام جوجل',
                                  style: AppTextStyles.buttonLarge,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
