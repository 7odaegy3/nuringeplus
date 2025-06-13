import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/3_home/data/models/procedure_model.dart';
import '../helpers/app_colors.dart';
import '../helpers/app_text_styles.dart';

class ProcedureCard extends StatelessWidget {
  final ProcedureModel procedure;
  final VoidCallback onTap;
  final bool isSaved;

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.onTap,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total steps from all arrays
    final totalSteps = [
      ...procedure.indicationsAr,
      ...procedure.contraindicationsAr,
      ...procedure.complicationsAr,
      ...procedure.toolsAr,
    ].length;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: isSaved
                ? const LinearGradient(
                    colors: [
                      AppColors.savedGradientStart,
                      AppColors.savedGradientEnd,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Title and Steps Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Steps Count
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 16.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$totalSteps خطوة',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        procedure.titleAr,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Overview
              Text(
                procedure.overviewAr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              // Category
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    procedure.categoryNameAr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.folder_outlined,
                    color: AppColors.primary,
                    size: 16.r,
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
