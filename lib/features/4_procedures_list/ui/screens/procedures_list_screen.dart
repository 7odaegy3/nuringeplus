import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/app_colors.dart';
import '../../../../core/helpers/app_text_styles.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/procedure_card.dart';
import '../../../3_home/data/models/procedure_model.dart';
import '../../../3_home/data/repos/home_repo.dart';

class ProceduresListScreen extends StatefulWidget {
  final int categoryId;

  const ProceduresListScreen({super.key, required this.categoryId});

  @override
  State<ProceduresListScreen> createState() => _ProceduresListScreenState();
}

class _ProceduresListScreenState extends State<ProceduresListScreen> {
  late Future<List<ProcedureModel>> _proceduresFuture;
  List<ProcedureModel> _allProcedures = [];
  List<ProcedureModel> _filteredProcedures = [];
  String _categoryName = '';

  @override
  void initState() {
    super.initState();
    _loadProcedures();
  }

  void _loadProcedures() {
    final homeRepo = HomeRepo();
    _proceduresFuture = homeRepo.getProceduresByCategory(widget.categoryId);
    _proceduresFuture.then((procedures) {
      setState(() {
        _allProcedures = procedures;
        _filteredProcedures = procedures;
        if (procedures.isNotEmpty) {
          _categoryName = procedures.first.categoryNameAr;
        }
      });
    });
  }

  void _filterProcedures(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProcedures = _allProcedures;
      } else {
        _filteredProcedures = _allProcedures
            .where(
              (procedure) =>
                  procedure.titleAr.contains(query) ||
                  procedure.overviewAr.contains(query),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _categoryName.isEmpty
              ? 'قائمة البروسيدجرات'
              : 'كل بروسيدجرات $_categoryName',
          style: AppTextStyles.h2,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(onChanged: _filterProcedures, autofocus: false),

          // Procedures List
          Expanded(
            child: FutureBuilder<List<ProcedureModel>>(
              future: _proceduresFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ أثناء تحميل البروسيدجرات',
                      style: AppTextStyles.bodyLarge,
                      textDirection: TextDirection.rtl,
                    ),
                  );
                }

                if (_filteredProcedures.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد بروسيدجرات',
                      style: AppTextStyles.bodyLarge,
                      textDirection: TextDirection.rtl,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredProcedures.length,
                  itemBuilder: (context, index) {
                    final procedure = _filteredProcedures[index];
                    return ProcedureCard(
                      title: procedure.titleAr,
                      category: procedure.categoryNameAr,
                      stepsCount: 32, // TODO: Get actual steps count
                      isViewed: procedure.isViewed,
                      isSaved: procedure.isSaved,
                      onTap: () =>
                          context.push('/procedure-details/${procedure.id}'),
                      onSaveToggle: () {
                        // TODO: Implement save toggle
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
