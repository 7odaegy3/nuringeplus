import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../data/models/procedure_model.dart';

class ProcedureListTile extends StatelessWidget {
  final ProcedureModel procedure;
  final VoidCallback onTap;

  const ProcedureListTile({
    super.key,
    required this.procedure,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                procedure.titleAr,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 4.h),
              Text(
                procedure.overviewAr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    procedure.categoryNameAr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                    textDirection: TextDirection.rtl,
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
