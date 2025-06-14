import 'package:equatable/equatable.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../data/models/category_model.dart';

class HomeState extends Equatable {
  final List<CategoryModel> categories;
  final List<Procedure> savedProcedures;
  final List<Procedure> searchResults;
  final bool isLoading;
  final bool isSearching;
  final String? error;

  const HomeState({
    this.categories = const [],
    this.savedProcedures = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.error,
  });

  HomeState copyWith({
    List<CategoryModel>? categories,
    List<Procedure>? savedProcedures,
    List<Procedure>? searchResults,
    bool? isLoading,
    bool? isSearching,
    String? error,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      savedProcedures: savedProcedures ?? this.savedProcedures,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        savedProcedures,
        searchResults,
        isLoading,
        isSearching,
        error,
      ];
}
