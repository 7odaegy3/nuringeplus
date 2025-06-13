import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/category_model.dart';

// Helper to get an icon from a string name
IconData _getIconFromString(String? iconName) {
  switch (iconName) {
    case 'child_care':
      return Icons.child_care;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'groups':
      return Icons.groups;
    default:
      return Icons.category; // Default icon
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final Gradient gradient;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconFromString(category.iconName),
              color: Colors.white,
              size: 40.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              category.nameAr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
