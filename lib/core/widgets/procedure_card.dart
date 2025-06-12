import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class ProcedureCard extends StatelessWidget {
  final String title;
  final String category;
  final int stepsCount;
  final bool isViewed;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

  const ProcedureCard({
    super.key,
    required this.title,
    required this.category,
    required this.stepsCount,
    this.isViewed = false,
    required this.onTap,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onSaveToggle != null)
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: isSaved
                            ? AppColors.primary
                            : AppColors.iconInactive,
                      ),
                      onPressed: onSaveToggle,
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$stepsCount خطوة',
                    style: AppTextStyles.bodySmall,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    isViewed ? Icons.visibility : Icons.visibility_outlined,
                    size: 16.r,
                    color: AppColors.iconInactive,
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
