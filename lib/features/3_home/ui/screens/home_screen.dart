import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../logic/cubit/home_cubit.dart';
import '../widgets/category_card.dart';
import '../widgets/saved_procedure_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePageData(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({super.key});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _searchController = TextEditingController();

  final List<Gradient> _gradients = const [
    LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFC62828)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        context.read<HomeCubit>().searchProcedures(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildHeader(state),
                _buildSearchBar(context),
                if (_searchController.text.isEmpty) ...[
                  _buildSectionTitle('الأقسام'),
                  _buildCategoriesGrid(context, state),
                  if (state.savedProcedures.isNotEmpty) ...[
                    _buildSectionTitle('آخر المحفوظات'),
                    _buildSavedProceduresList(context, state),
                    _buildViewAllButton(context),
                  ]
                ] else ...[
                  _buildSearchResults(state),
                ]
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 0),
    );
  }

  SliverToBoxAdapter _buildHeader(HomeState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello,',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text(
                  state.isGuest ? 'Visitor' : state.userName ?? 'User',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => AppRouter.goToSavedProcedures(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                ),
                child: const Icon(Icons.favorite,
                    color: Colors.blueAccent, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن أي بروسيدجر...',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  SliverPadding _buildCategoriesGrid(BuildContext context, HomeState state) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = state.categories[index];
            return CategoryCard(
              category: category,
              gradient: _gradients[index % _gradients.length],
              onTap: () =>
                  AppRouter.goToProceduresList(context, category.nameAr),
            );
          },
          childCount: state.categories.length,
        ),
      ),
    );
  }

  SliverList _buildSavedProceduresList(BuildContext context, HomeState state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final procedure = state.savedProcedures[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: SavedProcedureCard(
              procedure: procedure,
              onTap: () =>
                  AppRouter.goToProcedureDetails(context, procedure.id),
            ),
          );
        },
        childCount: state.savedProcedures.take(2).length, // Show max 2
      ),
    );
  }

  SliverToBoxAdapter _buildViewAllButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(right: 20, top: 10),
        child: GestureDetector(
          onTap: () => AppRouter.goToSavedProcedures(context),
          child: const Text(
            'أضغط هنا لعرض كل المحفوظات',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(HomeState state) {
    if (state.searchResults.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('لا توجد نتائج')),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final procedure = state.searchResults[index];
          final gradient = _gradients[index % _gradients.length];
          // Using a widget similar to ProcedureListScreen's card
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GestureDetector(
              onTap: () => AppRouter.goToProcedureDetails(context, procedure.id,
                  extra: gradient),
              child: Container(
                height: 120.h,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.medical_services,
                            color: Colors.white, size: 40),
                        SizedBox(height: 8.h),
                        Text(procedure.category ?? '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(procedure.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text('${procedure.stepCount} خطوة',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: state.searchResults.length,
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.settings_outlined, "الإعدادات", 2, currentIndex,
              () => context.push('/settings')),
          _buildNavItem(Icons.bookmark_border, "المحفوظات", 1, currentIndex,
              () => context.push('/saved-procedures')),
          _buildNavItem(Icons.home_filled, "الرئيسية", 0, currentIndex, () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int currentIndex,
      VoidCallback onTap) {
    final bool isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blueAccent : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
