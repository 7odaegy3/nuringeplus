import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/widgets/procedure_card.dart';
import '../cubit/procedures_list_cubit.dart';
import '../cubit/procedures_list_state.dart';

class ProceduresListScreen extends StatefulWidget {
  final int categoryId;

  const ProceduresListScreen({super.key, required this.categoryId});

  @override
  State<ProceduresListScreen> createState() => _ProceduresListScreenState();
}

class _ProceduresListScreenState extends State<ProceduresListScreen> {
  late final ProceduresListCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProceduresListCubit();
    _cubit.fetchProcedures(widget.categoryId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () => context.pop(),
      ),
      title: BlocBuilder<ProceduresListCubit, ProceduresListState>(
        builder: (context, state) {
          if (state is ProceduresListSuccess) {
            return Text(
              'كل بروسيدجرات ${state.categoryName}',
              style: AppTextStyles.h2,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ProceduresListCubit, ProceduresListState>(
      builder: (context, state) {
        if (state is ProceduresListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProceduresListFailure) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is ProceduresListSuccess) {
          if (state.procedures.isEmpty) {
            return Center(
              child: Text(
                'لا توجد بروسيدجرات في هذا التصنيف',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: state.procedures.length,
            itemBuilder: (context, index) {
              final procedure = state.procedures[index];
              return ProcedureCard(
                procedure: procedure,
                onTap: () {
                  context.go('/home/procedure-details/${procedure.id}');
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
