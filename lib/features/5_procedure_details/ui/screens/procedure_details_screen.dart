import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../logic/cubit/procedure_details_cubit.dart';
import '../../../6_saved_procedures/logic/cubit/saved_procedures_cubit.dart';
import '../../../6_saved_procedures/logic/cubit/saved_procedures_state.dart';

class ProcedureDetailsScreen extends StatefulWidget {
  final int procedureId;
  final Gradient? gradient;

  const ProcedureDetailsScreen({
    super.key,
    required this.procedureId,
    this.gradient,
  });

  @override
  State<ProcedureDetailsScreen> createState() => _ProcedureDetailsScreenState();
}

class _ProcedureDetailsScreenState extends State<ProcedureDetailsScreen> {
  final SqliteService _sqliteService = SqliteService();

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final isSaved = await _sqliteService.isProcedureSaved(widget.procedureId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleSave() async {
    final procedure = await _sqliteService.getProcedureById(widget.procedureId);
    if (procedure != null) {
      context.read<SavedProceduresCubit>().toggleSaveProcedure(procedure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الإجراء'),
        actions: [
          BlocBuilder<SavedProceduresCubit, SavedProceduresState>(
            builder: (context, state) {
              final isSaved =
                  state.procedures.any((p) => p.id == widget.procedureId);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.blue : null,
                ),
                onPressed: _toggleSave,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Procedure>(
        future: _sqliteService.getProcedureById(widget.procedureId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Procedure not found'));
          }

          final procedure = snapshot.data!;
          return CustomScrollView(
            slivers: [
              _buildHeader(procedure),
              _buildContent(procedure),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Procedure procedure) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: widget.gradient ??
              const LinearGradient(
                colors: [Colors.blue, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              procedure.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (procedure.category != null) ...[
              SizedBox(height: 8.h),
              Text(
                procedure.category!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16.sp,
                ),
              ),
            ],
            if (procedure.about != null) ...[
              SizedBox(height: 16.h),
              Text(
                procedure.about!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Procedure procedure) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'عدد الخطوات: ${procedure.stepCount}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add more content sections here
          ],
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.green,
                child: Text(
                  step.stepNumber.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.description,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              if (step.rational != null && step.rational!.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.lightbulb, color: Colors.amber.shade700),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Rational'),
                        content: Text(step.rational!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          )
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          if (step.extraNote != null && step.extraNote!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 42.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_alt,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.extraNote!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
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
    return _CustomExpansionTile(
      title: 'صور توضيحية',
      children: illustrations.map((illustration) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          // Assuming images are from assets.
          // User needs to ensure the asset paths are correct.
          child: Image.asset(
            illustration.imagePath,
            errorBuilder: (context, error, stackTrace) {
              return Text('Could not load image: ${illustration.imagePath}');
            },
          ),
        );
      }).toList(),
    );
  }
}
