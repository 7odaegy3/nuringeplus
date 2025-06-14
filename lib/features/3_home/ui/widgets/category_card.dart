import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/category_model.dart';

IconData _getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'respiratory':
    case 'تنفسي':
      return Icons.air;
    case 'cardiac':
    case 'قلبي':
      return Icons.favorite;
    case 'neurological':
    case 'عصبي':
      return Icons.psychology;
    case 'gastrointestinal':
    case 'هضمي':
      return Icons.lunch_dining;
    case 'urinary':
    case 'بولي':
      return Icons.water_drop;
    case 'musculoskeletal':
    case 'عضلي هيكلي':
      return Icons.accessibility_new;
    case 'skin':
    case 'جلدي':
      return Icons.healing;
    case 'reproductive':
    case 'تناسلي':
      return Icons.pregnant_woman;
    case 'endocrine':
    case 'غدد صماء':
      return Icons.biotech;
    case 'immune':
    case 'مناعي':
      return Icons.security;
    case 'general':
    case 'عام':
      return Icons.medical_services;
    default:
      return Icons.category_outlined;
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30.w,
              top: -30.h,
              child: Icon(
                _getCategoryIcon(category.nameAr),
                color: Colors.white.withOpacity(0.2),
                size: 120.sp,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.nameAr),
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    category.nameAr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
