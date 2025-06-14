import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../logic/cubit/procedures_list_cubit.dart';

class ProceduresListScreen extends StatelessWidget {
  final String categoryName;

  const ProceduresListScreen({
    super.key,
    required this.categoryName,
  });

  // List of gradients for the cards
  final List<Gradient> gradients = const [
    LinearGradient(
      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFF8008), Color(0xFFFFC837)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProceduresListCubit()..loadProcedures(categoryName),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: BlocBuilder<ProceduresListCubit, ProceduresListState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.error!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }

            final procedures = state.filteredProcedures;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 140.h,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: Colors.white,
                        child: SafeArea(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                height: constraints.maxHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            child: Icon(
                                              _getCategoryIcon(categoryName),
                                              color: AppColors.primary,
                                              size: 24.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Text(
                                              categoryName,
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 24.w,
                                        right: 24.w,
                                        bottom: 8.h,
                                      ),
                                      child: CustomSearchBar(
                                        hintText: 'ابحث في $categoryName...',
                                        onChanged: (query) {
                                          context
                                              .read<ProceduresListCubit>()
                                              .searchProcedures(query);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        16.w, 16.h, 16.w, kBottomNavigationBarHeight + 16.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final procedure = procedures[index];
                          return _ProcedureCard(
                            procedure: procedure,
                            gradient: gradients[index % gradients.length],
                            onTap: () => AppRouter.goToProcedureDetails(
                              context,
                              procedure.id,
                              extra: gradients[index % gradients.length],
                            ),
                          );
                        },
                        childCount: procedures.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  final Procedure procedure;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ProcedureCard({
    required this.procedure,
    required this.gradient,
    required this.onTap,
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
                Icons.medical_services_outlined,
                color: Colors.white.withOpacity(0.2),
                size: 120.sp,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      procedure.hasIllustrations
                          ? Icons.image_rounded
                          : Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    procedure.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.format_list_numbered,
                        color: Colors.white.withOpacity(0.8),
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${procedure.stepCount} خطوة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
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
