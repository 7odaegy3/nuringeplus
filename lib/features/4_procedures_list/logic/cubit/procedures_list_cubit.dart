import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../3_home/data/models/procedure_model.dart';

// Procedures List State
class ProceduresListState extends Equatable {
  final List<ProcedureModel> procedures;
  final List<ProcedureModel> filteredProcedures;
  final String? categoryName;
  final bool isLoading;
  final String? error;

  const ProceduresListState({
    this.procedures = const [],
    this.filteredProcedures = const [],
    this.categoryName,
    this.isLoading = false,
    this.error,
  });

  ProceduresListState copyWith({
    List<ProcedureModel>? procedures,
    List<ProcedureModel>? filteredProcedures,
    String? categoryName,
    bool? isLoading,
    String? error,
  }) {
    return ProceduresListState(
      procedures: procedures ?? this.procedures,
      filteredProcedures: filteredProcedures ?? this.filteredProcedures,
      categoryName: categoryName ?? this.categoryName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        procedures,
        filteredProcedures,
        categoryName,
        isLoading,
        error,
      ];
}

// Procedures List Cubit
class ProceduresListCubit extends Cubit<ProceduresListState> {
  final _sqliteService = SqliteService();

  ProceduresListCubit() : super(const ProceduresListState());

  Future<void> loadProcedures(int categoryId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final procedures =
          await _sqliteService.getProceduresByCategory(categoryId);
      final procedureModels =
          procedures.map((p) => ProcedureModel.fromMap(p)).toList();

      // Get category name from the first procedure
      final categoryName = procedures.isNotEmpty
          ? procedures.first['category_name_ar'] as String
          : null;

      emit(state.copyWith(
        procedures: procedureModels,
        categoryName: categoryName,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'حدث خطأ: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  void searchProcedures(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredProcedures: []));
      return;
    }

    final filteredProcedures = state.procedures.where((procedure) {
      return procedure.titleAr.contains(query) ||
          procedure.overviewAr.contains(query);
    }).toList();

    emit(state.copyWith(filteredProcedures: filteredProcedures));
  }
}
