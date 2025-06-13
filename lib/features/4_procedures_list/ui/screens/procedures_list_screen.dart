import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../logic/cubit/procedures_list_cubit.dart';
import '../widgets/procedure_list_item.dart';

class ProceduresListScreen extends StatelessWidget {
  final int categoryId;

  const ProceduresListScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProceduresListCubit()..loadProcedures(categoryId),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ProceduresListCubit, ProceduresListState>(
            builder: (context, state) {
              return Text(
                state.categoryName ?? 'قائمة البروسيدجرات',
                style: AppTextStyles.h2,
              );
            },
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<ProceduresListCubit, ProceduresListState>(
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

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: CustomSearchBar(
                    hintText: 'ابحث في البروسيدجرات...',
                    onChanged: (query) {
                      context
                          .read<ProceduresListCubit>()
                          .searchProcedures(query);
                    },
                  ),
                ),

                // Procedures List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: state.filteredProcedures.isEmpty
                        ? state.procedures.length
                        : state.filteredProcedures.length,
                    itemBuilder: (context, index) {
                      final procedure = state.filteredProcedures.isEmpty
                          ? state.procedures[index]
                          : state.filteredProcedures[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: ProcedureListItem(
                          procedure: procedure,
                          onTap: () => AppRouter.goToProcedureDetails(
                            context,
                            procedure.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
