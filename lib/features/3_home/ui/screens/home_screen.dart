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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePageData(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
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

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                                    style: AppTextStyles.h2,
                                  ),
                                  Text(
                                    state.isGuest
                                        ? 'زائر'
                                        : state.userName ?? '',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.favorite_border,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () =>
                                      AppRouter.goToSavedProcedures(context),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          CustomSearchBar(
                            hintText: 'ابحث عن أي بروسيدجر...',
                            onChanged: (query) {
                              context.read<HomeCubit>().searchProcedures(query);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
                      child: Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'الأقسام',
                            style: AppTextStyles.h2,
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
                          return CategoryCard(
                            category: category,
                            onTap: () => AppRouter.goToProceduresList(
                              context,
                              category.nameAr,
                            ),
                            gradient: _gradients[index % _gradients.length],
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
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'آخر المحفوظات',
                              style: AppTextStyles.h2,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () =>
                                  AppRouter.goToSavedProcedures(context),
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(
                                'عرض الكل',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final procedure = state.savedProcedures[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: SavedProcedureCard(
                                procedure: procedure,
                                onTap: () => AppRouter.goToProcedureDetails(
                                  context,
                                  procedure.id,
                                ),
                              ),
                            );
                          },
                          childCount: state.savedProcedures.length,
                        ),
                      ),
                    ),
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
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            elevation: 8,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              switch (index) {
                case 1:
                  AppRouter.goToSavedProcedures(context);
                  break;
                case 2:
                  AppRouter.goToSettings(context);
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_rounded),
                label: 'المحفوظات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'الإعدادات',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
