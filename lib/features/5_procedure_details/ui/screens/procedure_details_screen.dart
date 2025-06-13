import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../logic/cubit/procedure_details_cubit.dart';

class ProcedureDetailsScreen extends StatelessWidget {
  final int procedureId;

  const ProcedureDetailsScreen({
    super.key,
    required this.procedureId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProcedureDetailsCubit()..loadProcedure(procedureId),
      child: Scaffold(
        body: BlocBuilder<ProcedureDetailsCubit, ProcedureDetailsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }

            final procedure = state.procedure;
            if (procedure == null) {
              return const Center(child: Text('Procedure not found.'));
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00796B), // Teal
                          Color(0xFF2E7D32), // Green
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Column(
                      children: [
                        _CustomAppBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _HeaderSection(procedure: procedure),
                                _buildExpansionSections(procedure),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpansionSections(Procedure procedure) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (procedure.about?.isNotEmpty ?? false)
            _CustomExpansionTile(
              title: 'نبذة عن البروسيدجر',
              children: [
                Text(procedure.about!, style: const TextStyle(fontSize: 16))
              ],
            ),
          if (procedure.indications?.isNotEmpty ?? false)
            _CustomExpansionTile(
              title: 'Indications',
              children: [
                Text(procedure.indications!,
                    style: const TextStyle(fontSize: 16))
              ],
            ),
          if (procedure.contraindications?.isNotEmpty ?? false)
            _CustomExpansionTile(
              title: 'Contraindications',
              children: [
                Text(procedure.contraindications!,
                    style: const TextStyle(fontSize: 16))
              ],
            ),
          if (procedure.complications?.isNotEmpty ?? false)
            _CustomExpansionTile(
              title: 'Complications',
              children: [
                Text(procedure.complications!,
                    style: const TextStyle(fontSize: 16))
              ],
            ),
          if (procedure.requiredTools?.isNotEmpty ?? false)
            _CustomExpansionTile(
              title: 'الأدوات المطلوبة',
              children: [
                Text(procedure.requiredTools!,
                    style: const TextStyle(fontSize: 16))
              ],
            ),
          if (procedure.importantInfo?.isNotEmpty ?? false)
            _CustomExpansionTile(
              title: 'معلومات هامة',
              children: [
                Text(procedure.importantInfo!,
                    style: const TextStyle(fontSize: 16))
              ],
            ),
          if (procedure.implementations.isNotEmpty)
            _ImplementationsSection(implementations: procedure.implementations),
          if (procedure.illustrations.isNotEmpty)
            _IllustrationsSection(illustrations: procedure.illustrations),
        ],
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
