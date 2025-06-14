import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../logic/cubit/settings_cubit.dart';
import '../../logic/cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            shadowColor: Theme.of(context).shadowColor,
            title: Text(
              'الإعدادات',
              style: AppTextStyles.h2.copyWith(
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: [
                  // Dark Mode Toggle
                  _buildDarkModeTile(context, state.isDarkMode),

                  SizedBox(height: 16.h),

                  // Telegram Group
                  _buildSettingCard(
                    context: context,
                    title: 'انضم لمجموعة التليجرام',
                    subtitle: 'تواصل مع مجتمع التمريض',
                    icon: Icons.telegram,
                    onTap: () {
                      _launchUrl('https://t.me/your_telegram_group');
                    },
                    gradient: AppColors.accentGradient1,
                  ),

                  SizedBox(height: 16.h),

                  // YouTube Channel
                  _buildSettingCard(
                    context: context,
                    title: 'اشترك في قناة اليوتيوب',
                    subtitle: 'شاهد شروحات الإجراءات',
                    icon: Icons.play_circle_fill,
                    onTap: () {
                      _launchUrl('https://youtube.com/your_channel');
                    },
                    gradient: AppColors.accentGradient2,
                  ),

                  SizedBox(height: 16.h),

                  // Logout Button
                  _buildSettingCard(
                    context: context,
                    title: 'تسجيل الخروج',
                    subtitle: 'الخروج من التطبيق',
                    icon: Icons.logout,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          content: Text(
                            'هل أنت متأكد من تسجيل الخروج؟',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await context.read<SettingsCubit>().logout();
                                if (context.mounted) {
                                  AppRouter.goToLogin(context);
                                }
                              },
                              child: const Text(
                                'تأكيد',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    gradient: AppColors.accentGradient2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDarkModeTile(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? AppColors.getLightShadow()
            : AppColors.getDarkShadow(),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        title: Text(
          'الوضع الداكن',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          isDarkMode ? 'مفعل' : 'غير مفعل',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14.sp,
          ),
        ),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            context.read<SettingsCubit>().toggleDarkMode();
          },
          activeTrackColor: Colors.white.withOpacity(0.3),
          activeColor: Colors.white,
          inactiveTrackColor: Colors.white.withOpacity(0.1),
          inactiveThumbColor: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? AppColors.getLightShadow()
            : AppColors.getDarkShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
