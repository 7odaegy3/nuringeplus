import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../logic/cubit/procedures_list_cubit.dart';

class ProceduresListScreen extends StatelessWidget {
  final String categoryName;

  const ProceduresListScreen({
    super.key,
    required this.categoryName,
  });

  // List of gradients for the cards
  final List<Gradient> gradients = const [
    LinearGradient(
        colors: [Color(0xFF009688), Color(0xFF00695C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFC62828)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFF00897B), Color(0xFF00695C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProceduresListCubit()..loadProcedures(categoryName),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            categoryName,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<ProceduresListCubit, ProceduresListState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            final procedures = state.filteredProcedures;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: procedures.length,
                itemBuilder: (context, index) {
                  final procedure = procedures[index];
                  final gradient = gradients[index % gradients.length];
                  return _ProcedureCard(
                    procedure: procedure,
                    gradient: gradient,
                    onTap: () => AppRouter.goToProcedureDetails(
                      context,
                      procedure.id,
                      extra: gradient, // Pass gradient to details screen
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  final Procedure procedure;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ProcedureCard({
    required this.procedure,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130.h,
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Left Side: Category Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.child_care,
                    color: Colors.white, size: 40), // Placeholder
                SizedBox(height: 8.h),
                Text(
                  procedure.category ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Right Side: Procedure Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    procedure.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white, size: 16),
                      SizedBox(width: 4.w),
                      Text('${procedure.stepCount} خطوة',
                          style: const TextStyle(color: Colors.white)),
                      SizedBox(width: 16.w),
                      Icon(
                          procedure.hasIllustrations
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                          size: 16),
                      SizedBox(width: 4.w),
                      Text(procedure.infoText ?? '',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
