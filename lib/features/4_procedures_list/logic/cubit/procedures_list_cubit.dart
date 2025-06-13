import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/sqflite_service.dart';

// Procedures List State
class ProceduresListState extends Equatable {
  final List<Procedure> procedures;
  final List<Procedure> filteredProcedures;
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
    List<Procedure>? procedures,
    List<Procedure>? filteredProcedures,
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

  Future<void> loadProcedures(String categoryName) async {
    try {
      emit(state.copyWith(isLoading: true, categoryName: categoryName));

      final procedures =
          await _sqliteService.getProceduresByCategory(categoryName);

      emit(state.copyWith(
        procedures: procedures,
        filteredProcedures: procedures,
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
      emit(state.copyWith(filteredProcedures: state.procedures));
      return;
    }

    final filteredProcedures = state.procedures.where((procedure) {
      return procedure.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(filteredProcedures: filteredProcedures));
  }
}
