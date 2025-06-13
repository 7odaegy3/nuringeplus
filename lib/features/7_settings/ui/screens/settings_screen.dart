import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/api/firebase_service.dart';
import '../../../../core/routing/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: AppTextStyles.h2,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSection(
            title: 'الحساب',
            children: [
              _buildListTile(
                icon: Icons.person_outline,
                title: 'الملف الشخصي',
                onTap: () {
                  // TODO: Navigate to profile screen
                },
              ),
              _buildListTile(
                icon: Icons.notifications_none,
                title: 'الإشعارات',
                onTap: () {
                  // TODO: Navigate to notifications settings
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSection(
            title: 'التطبيق',
            children: [
              _buildListTile(
                icon: Icons.language,
                title: 'اللغة',
                trailing: const Text('العربية'),
                onTap: () {
                  // TODO: Show language picker
                },
              ),
              _buildListTile(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSection(
            title: 'أخرى',
            children: [
              _buildListTile(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                onTap: () async {
                  await FirebaseService().signOut();
                  if (context.mounted) {
                    AppRouter.goToLogin(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
      onTap: onTap,
    );
  }
}
