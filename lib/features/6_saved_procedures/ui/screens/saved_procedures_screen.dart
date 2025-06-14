import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../logic/cubit/saved_procedures_cubit.dart';
import '../../logic/cubit/saved_procedures_state.dart';

class SavedProceduresScreen extends StatefulWidget {
  const SavedProceduresScreen({super.key});

  @override
  State<SavedProceduresScreen> createState() => _SavedProceduresScreenState();
}

class _SavedProceduresScreenState extends State<SavedProceduresScreen> {
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
        context
            .read<SavedProceduresCubit>()
            .searchSavedProcedures(_searchController.text);
      }
    });
    // Load saved procedures when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedProceduresCubit>().loadSavedProcedures();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _removeProcedure(
      BuildContext context, Procedure procedure) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الإجراء من المحفوظات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<SavedProceduresCubit>().toggleSaveProcedure(procedure);
      // Force a rebuild of the list
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<SavedProceduresCubit, SavedProceduresState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                _buildHeader(state),
                _buildSearchBar(),
                _buildProceduresList(state),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }

  SliverToBoxAdapter _buildHeader(SavedProceduresState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello, User First Name, this is',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                const Text(
                  'Saved Procedures',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
              ),
              child: const Icon(Icons.favorite,
                  color: Colors.blueAccent, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث من خلال قائمتك المحفوظة',
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

  Widget _buildProceduresList(SavedProceduresState state) {
    final procedures = _searchController.text.isEmpty
        ? List<Procedure>.from(
            state.procedures) // Create a new list to force rebuild
        : List<Procedure>.from(state.searchResults);

    if (procedures.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            _searchController.text.isEmpty
                ? 'لا توجد إجراءات محفوظة'
                : 'لا توجد نتائج',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final procedure = procedures[index];
          final gradient = _gradients[index % _gradients.length];

          return Dismissible(
            key: ValueKey(
                'saved_procedure_${procedure.id}_${DateTime.now().millisecondsSinceEpoch}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) => _removeProcedure(context, procedure),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GestureDetector(
                onTap: () => AppRouter.goToProcedureDetails(
                  context,
                  procedure.id,
                  extra: gradient,
                ),
                child: Container(
                  height: 120.h,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(procedure.category),
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 8.h),
                          if (procedure.category != null)
                            Text(
                              procedure.category!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              procedure.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${procedure.stepCount} خطوة',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.sunny,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'نعم',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: procedures.length,
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'تمريض الأطفال':
        return Icons.child_care;
      case 'الرعاية المركزة':
        return Icons.local_hospital;
      default:
        return Icons.medical_services;
    }
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
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.settings_outlined, "الإعدادات", 2, currentIndex,
              () => context.push('/settings')),
          _buildNavItem(
              Icons.bookmark_border, "المحفوظات", 1, currentIndex, () {}),
          _buildNavItem(Icons.home_filled, "الرئيسية", 0, currentIndex,
              () => context.push('/')),
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
