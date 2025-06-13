import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../3_home/data/models/checklist_item_model.dart';
import 'step_checklist.dart';
import 'video_player_section.dart';

class ImplementationStep extends StatelessWidget {
  final int stepNumber;
  final String stepEn;
  final String rationalAr;
  final String? videoUrl;
  final List<ChecklistItemModel> checklistItems;
  final Function(int, bool)? onChecklistItemToggle;

  const ImplementationStep({
    super.key,
    required this.stepNumber,
    required this.stepEn,
    required this.rationalAr,
    this.videoUrl,
    this.checklistItems = const [],
    this.onChecklistItemToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  stepEn,
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            ],
          ),
          if (videoUrl != null) ...[
            SizedBox(height: 16.h),
            VideoPlayerSection(videoUrl: videoUrl!),
          ],
          SizedBox(height: 16.h),
          Text(
            'Rational:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            rationalAr,
            style: AppTextStyles.bodyMedium,
          ),
          if (checklistItems.isNotEmpty && onChecklistItemToggle != null) ...[
            SizedBox(height: 16.h),
            StepChecklist(
              items: checklistItems,
              onItemToggle: onChecklistItemToggle!,
            ),
          ],
        ],
      ),
    );
  }
}
