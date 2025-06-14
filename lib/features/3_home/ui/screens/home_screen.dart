import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../logic/cubit/home_cubit.dart';
import '../widgets/category_card.dart';
import '../widgets/saved_procedure_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // List of gradients for category cards
  final List<Gradient> _gradients = const [
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

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.medical_services;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePageData(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 8.w,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'جاري التحميل...',
                        style: AppTextStyles.h3.copyWith(color: textColor),
                      ),
                    ],
                  ),
                );
              }

              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.error!,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<HomeCubit>().loadHomePageData(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32.r),
                          bottomRight: Radius.circular(32.r),
                        ),
                        boxShadow: isDark
                            ? AppColors.getDarkShadow(opacity: 0.2)
                            : AppColors.getLightShadow(),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مرحباً،',
                                    style: AppTextStyles.h2.copyWith(
                                      color: textColor,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  Text(
                                    state.isGuest
                                        ? 'زائر'
                                        : state.userName ?? '',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Hero(
                                tag: 'saved_procedures_button',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withOpacity(0.2),
                                          AppColors.primary.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.favorite),
                                      color: AppColors.primary,
                                      onPressed: () =>
                                          AppRouter.goToSavedProcedures(
                                              context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Hero(
                            tag: 'search_bar',
                            child: Material(
                              color: Colors.transparent,
                              child: CustomSearchBar(
                                hintText: 'ابحث عن أي بروسيدجر...',
                                onChanged: (query) {
                                  context
                                      .read<HomeCubit>()
                                      .searchProcedures(query);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Results Section
                  if (state.searchResults.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
                        child: Row(
                          children: [
                            Container(
                              width: 4.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'نتائج البحث',
                              style:
                                  AppTextStyles.h2.copyWith(color: textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final procedure = state.searchResults[index];
                            return Hero(
                              tag: 'procedure_${procedure.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: GestureDetector(
                                  onTap: () => AppRouter.goToProcedureDetails(
                                    context,
                                    procedure.id,
                                    extra:
                                        _gradients[index % _gradients.length],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient:
                                          _gradients[index % _gradients.length],
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: isDark
                                          ? AppColors.getDarkShadow(
                                              opacity: 0.3)
                                          : AppColors.getLightShadow(),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: -30.w,
                                          top: -30.h,
                                          child: Icon(
                                            _getCategoryIcon(
                                                procedure.category),
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            size: 120.sp,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(16.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8.w),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Icon(
                                                  _getCategoryIcon(
                                                      procedure.category),
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
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 6.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .format_list_numbered,
                                                      color: Colors.white,
                                                      size: 16.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      '${procedure.stepCount} خطوة',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: state.searchResults.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 32.h),
                    ),
                  ],

                  if (state.searchResults.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
                        child: Row(
                          children: [
                            Container(
                              width: 4.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'الأقسام',
                              style:
                                  AppTextStyles.h2.copyWith(color: textColor),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Categories Section
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 1.1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = state.categories[index];
                            return Hero(
                              tag: 'category_${category.nameAr}',
                              child: Material(
                                color: Colors.transparent,
                                child: CategoryCard(
                                  category: category,
                                  onTap: () => AppRouter.goToProceduresList(
                                    context,
                                    category.nameAr,
                                  ),
                                  gradient:
                                      _gradients[index % _gradients.length],
                                ),
                              ),
                            );
                          },
                          childCount: state.categories.length,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: 32.h),
                    ),

                    // Recent Saved Procedures
                    if (state.savedProcedures.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
                          child: Row(
                            children: [
                              Container(
                                width: 4.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'آخر المحفوظات',
                                style:
                                    AppTextStyles.h2.copyWith(color: textColor),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () =>
                                    AppRouter.goToSavedProcedures(context),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('عرض الكل'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  textStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 180.h,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.savedProcedures.length,
                            itemBuilder: (context, index) {
                              final procedure = state.savedProcedures[index];
                              return Hero(
                                tag: 'saved_procedure_${procedure.id}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 160.w,
                                    margin: EdgeInsetsDirectional.only(
                                      end: index !=
                                              state.savedProcedures.length - 1
                                          ? 16.w
                                          : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient:
                                          _gradients[index % _gradients.length],
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: isDark
                                          ? AppColors.getDarkShadow(
                                              opacity: 0.3)
                                          : AppColors.getLightShadow(),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () =>
                                            AppRouter.goToProcedureDetails(
                                          context,
                                          procedure.id,
                                          extra: _gradients[
                                              index % _gradients.length],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              right: -30.w,
                                              top: -30.h,
                                              child: Icon(
                                                _getCategoryIcon(
                                                    procedure.category),
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                size: 120.sp,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16.w),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(8.w),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.r),
                                                    ),
                                                    child: Icon(
                                                      _getCategoryIcon(
                                                          procedure.category),
                                                      color: Colors.white,
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 16.h),
                                                  Text(
                                                    procedure.name,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.sp,
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 6.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.r),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .format_list_numbered,
                                                          color: Colors.white,
                                                          size: 16.sp,
                                                        ),
                                                        SizedBox(width: 4.w),
                                                        Text(
                                                          '${procedure.stepCount} خطوة',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],

                  // Bottom Padding
                  SliverToBoxAdapter(
                    child: SizedBox(height: 24.h),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
