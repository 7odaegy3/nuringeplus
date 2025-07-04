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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePageData(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً،',
                                style: AppTextStyles.h2,
                              ),
                              Text(
                                state.isGuest ? 'زائر' : state.userName ?? '',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () =>
                                AppRouter.goToSavedProcedures(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: CustomSearchBar(
                        hintText: 'ابحث عن أي بروسيدجر...',
                        onChanged: (query) {
                          context.read<HomeCubit>().searchProcedures(query);
                        },
                      ),
                    ),
                  ),

                  // Categories Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'الأقسام',
                        style: AppTextStyles.h2,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120.h,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.categories.length,
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 8.h,
                            ),
                            child: CategoryCard(
                              category: category,
                              onTap: () => AppRouter.goToProceduresList(
                                context,
                                category.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Recent Saved Procedures
                  if (state.savedProcedures.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Row(
                          children: [
                            Text(
                              'آخر المحفوظات',
                              style: AppTextStyles.h2,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  AppRouter.goToSavedProcedures(context),
                              child: Text(
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
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final procedure = state.savedProcedures[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 8.h,
                            ),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
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
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'المحفوظات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
