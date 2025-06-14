import 'package:equatable/equatable.dart';
import '../../../../core/database/sqflite_service.dart';

class SavedProceduresState extends Equatable {
  final List<Procedure> procedures;
  final List<Procedure> searchResults;
  final bool isLoading;
  final String? error;

  const SavedProceduresState({
    this.procedures = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  SavedProceduresState copyWith({
    List<Procedure>? procedures,
    List<Procedure>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return SavedProceduresState(
      procedures: procedures ?? this.procedures,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [procedures, searchResults, isLoading, error];
}
