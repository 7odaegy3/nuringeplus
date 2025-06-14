import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/services/search_service.dart';

// Procedures List State
class ProceduresListState extends Equatable {
  final List<Procedure> procedures;
  final List<Procedure> filteredProcedures;
  final String? categoryName;
  final bool isLoading;
  final bool isSearching;
  final String? error;

  const ProceduresListState({
    this.procedures = const [],
    this.filteredProcedures = const [],
    this.categoryName,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
  });

  ProceduresListState copyWith({
    List<Procedure>? procedures,
    List<Procedure>? filteredProcedures,
    String? categoryName,
    bool? isLoading,
    bool? isSearching,
    String? error,
  }) {
    return ProceduresListState(
      procedures: procedures ?? this.procedures,
      filteredProcedures: filteredProcedures ?? this.filteredProcedures,
      categoryName: categoryName ?? this.categoryName,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        procedures,
        filteredProcedures,
        categoryName,
        isLoading,
        isSearching,
        error,
      ];
}

// Procedures List Cubit
class ProceduresListCubit extends Cubit<ProceduresListState> {
  final SqliteService _sqliteService = SqliteService();
  late final SearchService _searchService;

  ProceduresListCubit() : super(const ProceduresListState()) {
    _searchService = SearchService(_sqliteService);
  }

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

  Future<void> searchProcedures(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(filteredProcedures: state.procedures));
      return;
    }

    try {
      emit(state.copyWith(isSearching: true));
      final results = await _searchService.searchProcedures(
        query,
        categoryFilter: state.categoryName,
      );
      emit(state.copyWith(
        filteredProcedures: results,
        isSearching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isSearching: false,
      ));
    }
  }
}
