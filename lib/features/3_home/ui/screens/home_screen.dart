import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/procedure_card.dart';
import '../../data/models/category_model.dart';
import '../../data/models/procedure_model.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/state/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // App Bar with User Name
                _buildAppBar(context),

                // Search Bar
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: CustomSearchBar(
                    onChanged: (query) {
                      context.read<HomeCubit>().searchProcedures(query);
                    },
                  ),
                ),

                // Main Content
                Expanded(
                  child: state is HomeLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state is HomeError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.message,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<HomeCubit>()
                                          .loadHomePageData();
                                    },
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            )
                          : state is HomeLoaded
                              ? _buildContent(context, state)
                              : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: user?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user!.photoURL!,
                      width: 40.r,
                      height: 40.r,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                user?.displayName ?? 'زائر',
                style: AppTextStyles.h3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().loadHomePageData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories Grid
              if (!state.isSearching) ...[
                SizedBox(height: 24.h),
                Text(
                  'التصنيفات',
                  style: AppTextStyles.h2,
                ),
                SizedBox(height: 16.h),
                _buildCategoriesGrid(context, state.categories),
              ],

              // Search Results or Recent Saved Procedures
              SizedBox(height: 24.h),
              Text(
                state.isSearching ? 'نتائج البحث' : 'الإجراءات المحفوظة',
                style: AppTextStyles.h2,
              ),
              SizedBox(height: 16.h),
              state.isSearching
                  ? _buildSearchResults(context, state.searchResults)
                  : _buildRecentSavedProcedures(
                      context, state.recentSavedProcedures),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(
      BuildContext context, List<CategoryModel> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            context.push('/home/procedures-list/${category.id}');
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: category.gradientColors
                    .map((c) => Color(int.parse(c)))
                    .toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconData(
                    int.parse(category.iconName),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Colors.white,
                  size: 32.r,
                ),
                SizedBox(height: 8.h),
                Text(
                  category.nameAr,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(
      BuildContext context, List<ProcedureModel> procedures) {
    if (procedures.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Text(
            'لا توجد نتائج',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: procedures.length,
      itemBuilder: (context, index) {
        final procedure = procedures[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: ProcedureCard(
            title: procedure.titleAr,
            category: procedure.categoryNameAr,
            stepsCount: 32, // TODO: Get actual steps count
            isViewed: procedure.isViewed,
            isSaved: procedure.isSaved,
            onTap: () => context.push('/procedure-details/${procedure.id}'),
            onSaveToggle: () {
              // TODO: Implement save toggle
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentSavedProcedures(
      BuildContext context, List<ProcedureModel> procedures) {
    if (procedures.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Text(
            'لا توجد إجراءات محفوظة',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: procedures.length,
      itemBuilder: (context, index) {
        final procedure = procedures[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: ProcedureCard(
            title: procedure.titleAr,
            category: procedure.categoryNameAr,
            stepsCount: 32, // TODO: Get actual steps count
            isViewed: procedure.isViewed,
            isSaved: procedure.isSaved,
            onTap: () => context.push('/procedure-details/${procedure.id}'),
            onSaveToggle: () {
              // TODO: Implement save toggle
            },
          ),
        );
      },
    );
  }
}
