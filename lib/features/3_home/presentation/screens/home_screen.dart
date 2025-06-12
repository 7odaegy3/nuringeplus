import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../data/models/category_model.dart';
import '../../data/models/procedure_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/category_card.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/procedure_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit();
    _homeCubit.loadHomePageData();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeSuccess) {
            return Text(
              state.userName != null
                  ? 'مرحباً، ${state.userName}'
                  : 'مرحباً، زائر',
              style: AppTextStyles.h2,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.primary),
          onPressed: () => context.go('/saved-procedures'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeFailure) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is HomeSuccess) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: CustomSearchBar(
                    hintText: 'ابحث عن أي بروسيدجر...',
                    onChanged: (query) {
                      context.read<HomeCubit>().searchProcedures(query);
                    },
                  ),
                ),

                // Search Results
                if (state.isSearching)
                  const Center(child: CircularProgressIndicator())
                else if (state.searchResults.isNotEmpty)
                  _buildSearchResults(state.searchResults)
                else
                  _buildMainContent(state),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMainContent(HomeSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text('التصنيفات', style: AppTextStyles.h2),
        ),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              return CategoryCard(
                category: state.categories[index],
                onTap: () {
                  context.read<HomeCubit>().loadProceduresByCategory(
                    state.categories[index].id,
                  );
                },
              );
            },
          ),
        ),

        // Recent Saved Section
        if (state.isUserLoggedIn && state.recentSavedProcedures.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text('آخر المحفوظات', style: AppTextStyles.h2),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: state.recentSavedProcedures.length,
            itemBuilder: (context, index) {
              return ProcedureListTile(
                procedure: state.recentSavedProcedures[index],
                onTap: () {
                  context.go(
                    '/home/procedure-details/${state.recentSavedProcedures[index].id}',
                  );
                },
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextButton(
              onPressed: () => context.go('/saved-procedures'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              ),
              child: Text(
                'اضغط هنا لعرض كل المحفوظات',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults(List<ProcedureModel> procedures) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: procedures.length,
      itemBuilder: (context, index) {
        return ProcedureListTile(
          procedure: procedures[index],
          onTap: () {
            context.go('/home/procedure-details/${procedures[index].id}');
          },
        );
      },
    );
  }
}
