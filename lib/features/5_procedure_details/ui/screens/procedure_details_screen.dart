import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/animations/custom_animations.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../logic/cubit/procedure_details_cubit.dart';
import '../../../6_saved_procedures/logic/cubit/saved_procedures_cubit.dart';
import '../../../6_saved_procedures/logic/cubit/saved_procedures_state.dart';

class ProcedureDetailsScreen extends StatefulWidget {
  final int procedureId;
  final Gradient? gradient;

  const ProcedureDetailsScreen({
    Key? key,
    required this.procedureId,
    this.gradient,
  }) : super(key: key);

  @override
  State<ProcedureDetailsScreen> createState() => _ProcedureDetailsScreenState();
}

class _ProcedureDetailsScreenState extends State<ProcedureDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  bool _isScrolled = false;
  final SqliteService _sqliteService = SqliteService();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _checkIfSaved();
  }

  void _onScroll() {
    if (_scrollController.offset > 140 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 140 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkIfSaved() async {
    final isSaved = await _sqliteService.isProcedureSaved(widget.procedureId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleSave() async {
    final procedure = await _sqliteService.getProcedureById(widget.procedureId);
    context.read<SavedProceduresCubit>().toggleSaveProcedure(procedure);
  }

  @override
  Widget build(BuildContext context) {
    final defaultGradient = LinearGradient(
      colors: [
        Theme.of(context).primaryColor.withOpacity(0.8),
        Theme.of(context).primaryColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<ProcedureDetailsCubit, ProcedureDetailsState>(
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

          if (state.procedure == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لم يتم العثور على الإجراء',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200.h,
                pinned: true,
                stretch: true,
                elevation: _isScrolled ? 4 : 0,
                backgroundColor: _isScrolled
                    ? (widget.gradient?.colors.first ??
                        Theme.of(context).primaryColor)
                    : Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: widget.gradient ?? defaultGradient,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                                Colors.black.withOpacity(0.4),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20.h,
                          left: 20.w,
                          right: 20.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.procedure!.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(
                                        state.procedure!.category ?? ''),
                                    color: Colors.white70,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    state.procedure!.category ?? '',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
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
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  BlocBuilder<SavedProceduresCubit, SavedProceduresState>(
                    builder: (context, savedState) {
                      final isSaved = savedState.procedures
                          .any((p) => p.id == widget.procedureId);
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if (state.procedure != null) {
                              context
                                  .read<SavedProceduresCubit>()
                                  .toggleSaveProcedure(state.procedure!);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.procedure!.about != null) ...[
                        _buildSectionTitle(
                            'نبذة عن الإجراء', Icons.info_outline),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            state.procedure!.about!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                      if (state.procedure!.indications != null)
                        _buildExpandableCard(
                          title: 'دواعي الاستخدام',
                          content: state.procedure!.indications!,
                          icon: Icons.check_circle_outline,
                          color: Colors.green.shade700,
                        ),
                      if (state.procedure!.contraindications != null)
                        _buildExpandableCard(
                          title: 'موانع الاستخدام',
                          content: state.procedure!.contraindications!,
                          icon: Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                        ),
                      if (state.procedure!.complications != null)
                        _buildExpandableCard(
                          title: 'المضاعفات المحتملة',
                          content: state.procedure!.complications!,
                          icon: Icons.error_outline,
                          color: Colors.orange.shade700,
                        ),
                      if (state.procedure!.requiredTools != null)
                        _buildExpandableCard(
                          title: 'الأدوات المطلوبة',
                          content: state.procedure!.requiredTools!,
                          icon: Icons.medical_services_outlined,
                          color: Colors.blue.shade700,
                        ),
                      SizedBox(height: 24.h),
                      _buildImplementationsSection(
                          state.procedure!.implementations),
                      SizedBox(height: 16.h),
                      if (state.procedure!.hasIllustrations)
                        _buildIllustrationsSection(
                            state.procedure!.illustrations),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Procedure procedure) {
    return SliverToBoxAdapter(
      child: CustomAnimations.fadeSlideTransition(
        animation: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (procedure.about != null) ...[
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  procedure.about!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildImplementationsSection(List<Implementation> implementations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('خطوات الإجراء', Icons.format_list_numbered),
        SizedBox(height: 16.h),
        ...implementations.map((step) => _StepWidget(step: step)),
      ],
    );
  }

  Widget _buildIllustrationsSection(List<Illustration> illustrations) {
    return _IllustrationsSection(illustrations: illustrations);
  }

  Widget _buildExpandableCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          childrenPadding: EdgeInsets.all(16.w),
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: color.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

// --- Custom Widgets for this screen ---

class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.bookmark_border,
                color: Colors.white, size: 30),
            onPressed: () {
              // TODO: Implement bookmark functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 30),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Procedure procedure;
  const _HeaderSection({required this.procedure});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            procedure.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          const Text(
            'responsive', // Placeholder as in image
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoIcon(
                icon: Icons.child_care, // Placeholder for category_icon
                text: procedure.category ?? '',
              ),
              _InfoIcon(
                icon: Icons.lightbulb_outline, // Placeholder for info_icon
                text: procedure.infoText ?? '',
              ),
              _InfoIcon(
                icon: Icons.error_outline, // Placeholder for steps icon
                text: '${procedure.implementations.length} خطوة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        SizedBox(height: 4.h),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _CustomExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _CustomExpansionTile({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.all(16.0),
        children: children,
      ),
    );
  }
}

class _ImplementationsSection extends StatelessWidget {
  final List<Implementation> implementations;
  const _ImplementationsSection({required this.implementations});

  @override
  Widget build(BuildContext context) {
    return _CustomExpansionTile(
      title: 'الخطوات (Implementations)',
      initiallyExpanded: true,
      children: implementations.map((step) => _StepWidget(step: step)).toList(),
    );
  }
}

class _StepWidget extends StatelessWidget {
  final Implementation step;
  const _StepWidget({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      step.stepNumber.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                if (step.rational != null && step.rational!.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber.shade700,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.amber.shade700,
                              ),
                              SizedBox(width: 8.w),
                              const Text('السبب العلمي'),
                            ],
                          ),
                          content: Text(
                            step.rational!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.5,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('إغلاق'),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (step.hint != null && step.hint!.isNotEmpty)
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.amber.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber.shade700,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      step.hint!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.amber.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _IllustrationsSection extends StatelessWidget {
  final List<Illustration> illustrations;
  const _IllustrationsSection({required this.illustrations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image,
              color: Theme.of(context).primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'الصور التوضيحية',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...illustrations.map((illustration) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                illustration.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200.h,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'تعذر تحميل الصورة',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
