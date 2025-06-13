import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../logic/cubit/procedure_details_cubit.dart';
import '../widgets/expandable_section.dart';
import '../widgets/implementation_step.dart';
import '../widgets/video_player_section.dart';

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
        appBar: AppBar(
          title: BlocBuilder<ProcedureDetailsCubit, ProcedureDetailsState>(
            builder: (context, state) {
              return Text(
                state.procedure?.titleAr ?? 'تفاصيل البروسيدجر',
                style: AppTextStyles.h2,
              );
            },
          ),
          actions: [
            BlocBuilder<ProcedureDetailsCubit, ProcedureDetailsState>(
              builder: (context, state) {
                if (state.isGuest) return const SizedBox();
                return IconButton(
                  icon: Icon(
                    state.isSaved ? Icons.favorite : Icons.favorite_border,
                    color: state.isSaved ? AppColors.error : null,
                  ),
                  onPressed: () {
                    context.read<ProcedureDetailsCubit>().toggleSaveStatus();
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ProcedureDetailsCubit, ProcedureDetailsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Text(
                  state.error!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (state.procedure == null) {
              return Center(
                child: Text(
                  'لم يتم العثور على البروسيدجر',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Overview Section
                ExpandableSection(
                  title: 'نبذة عن البروسيدجر',
                  initiallyExpanded: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.procedure!.overviewAr,
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (state.procedure!.videoUrl != null) ...[
                        SizedBox(height: 16.h),
                        VideoPlayerSection(
                          videoUrl: state.procedure!.videoUrl!,
                        ),
                      ],
                    ],
                  ),
                ),

                // Indications Section
                if (state.procedure!.indicationsAr.isNotEmpty)
                  ExpandableSection(
                    title: 'Indications',
                    child: Column(
                      children: state.procedure!.indicationsAr
                          .map((item) => _buildBulletPoint(item))
                          .toList(),
                    ),
                  ),

                // Contraindications Section
                if (state.procedure!.contraindicationsAr.isNotEmpty)
                  ExpandableSection(
                    title: 'Contraindications',
                    child: Column(
                      children: state.procedure!.contraindicationsAr
                          .map((item) => _buildBulletPoint(item))
                          .toList(),
                    ),
                  ),

                // Complications Section
                if (state.procedure!.complicationsAr.isNotEmpty)
                  ExpandableSection(
                    title: 'Complications',
                    child: Column(
                      children: state.procedure!.complicationsAr
                          .map((item) => _buildBulletPoint(item))
                          .toList(),
                    ),
                  ),

                // Tools Section
                if (state.procedure!.toolsAr.isNotEmpty)
                  ExpandableSection(
                    title: 'الأدوات المطلوبة',
                    child: Column(
                      children: state.procedure!.toolsAr
                          .map((item) => _buildBulletPoint(item))
                          .toList(),
                    ),
                  ),

                // Implementation Steps Section
                if (state.steps.isNotEmpty)
                  ExpandableSection(
                    title: 'الـ implementations',
                    child: Column(
                      children: state.steps.map((step) {
                        final stepIndex = state.steps.indexOf(step);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: ImplementationStep(
                            stepNumber: stepIndex + 1,
                            stepEn: step.stepEn,
                            rationalAr: step.rationalAr,
                            videoUrl: step.videoUrl,
                            checklistItems: state.checklistItems[step.id] ?? [],
                            onChecklistItemToggle: state.isGuest
                                ? null
                                : (itemId, isCompleted) {
                                    context
                                        .read<ProcedureDetailsCubit>()
                                        .toggleChecklistItem(
                                            itemId, isCompleted);
                                  },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Extra Info Section
                if (state.procedure!.extraInfoAr.isNotEmpty)
                  ExpandableSection(
                    title: 'معلومات هامة',
                    child: Text(
                      state.procedure!.extraInfoAr,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),

                // Progress Section (for authenticated users)
                if (!state.isGuest)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تقدمك',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            LinearProgressIndicator(
                              value: state.steps.isEmpty
                                  ? 0
                                  : state.completedSteps.length /
                                      state.steps.length,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'اكتمل ${state.completedSteps.length} من ${state.steps.length} خطوات',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              height: 1,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
