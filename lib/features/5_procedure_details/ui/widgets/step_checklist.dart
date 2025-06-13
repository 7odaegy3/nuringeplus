import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../3_home/data/models/checklist_item_model.dart';

class StepChecklist extends StatelessWidget {
  final List<ChecklistItemModel> items;
  final Function(int, bool) onItemToggle;

  const StepChecklist({
    super.key,
    required this.items,
    required this.onItemToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'قائمة التحقق',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        ...items.map((item) => _buildChecklistItem(item)).toList(),
      ],
    );
  }

  Widget _buildChecklistItem(ChecklistItemModel item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Checkbox(
            value: item.isCompleted,
            onChanged: (value) => onItemToggle(item.id, value ?? false),
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Text(
              item.itemText,
              style: AppTextStyles.bodyMedium.copyWith(
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : null,
                color: item.isCompleted ? AppColors.grey : null,
              ),
            ),
          ),
          if (item.isRequired)
            Icon(
              Icons.star,
              color: AppColors.warning,
              size: 16.w,
            ),
        ],
      ),
    );
  }
}
