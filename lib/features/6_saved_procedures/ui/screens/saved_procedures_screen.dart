import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/widgets/custom_search_bar.dart';
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
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        context
            .read<SavedProceduresCubit>()
            .searchSavedProcedures(_searchController.text);
      }
    });
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
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<SavedProceduresCubit>().toggleSaveProcedure(procedure);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

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
                        onPressed: () => context.go('/home'),
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
                                              Icons.favorite_rounded,
                                              color: AppColors.primary,
                                              size: 24.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Text(
                                            'المحفوظات',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
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
                                        hintText: 'ابحث في المحفوظات...',
                                        onChanged: (query) {
                                          context
                                              .read<SavedProceduresCubit>()
                                              .searchSavedProcedures(query);
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
                  if (state.procedures.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border_rounded,
                              size: 64.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد إجراءات محفوظة',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
                            final procedure = state.procedures[index];
                            return Dismissible(
                              key: ValueKey(
                                  'saved_procedure_${procedure.id}_${DateTime.now().millisecondsSinceEpoch}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 32.sp,
                                ),
                              ),
                              onDismissed: (_) =>
                                  _removeProcedure(context, procedure),
                              child: GestureDetector(
                                onTap: () => AppRouter.goToProcedureDetails(
                                  context,
                                  procedure.id,
                                  extra: _gradients[index % _gradients.length],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient:
                                        _gradients[index % _gradients.length],
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
                                          _getCategoryIcon(procedure.category),
                                          color: Colors.white.withOpacity(0.2),
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
                                                    BorderRadius.circular(12.r),
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
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.format_list_numbered,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  size: 16.sp,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  '${procedure.stepCount} خطوة',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
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
                              ),
                            );
                          },
                          childCount: state.procedures.length,
                        ),
                      ),
                    ),
                ],
              ),
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
          currentIndex: 1,
          elevation: 8,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/home');
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
    );
  }
}
