import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';
import '../../data/models/procedure_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<ProcedureModel> recentSavedProcedures;
  final List<ProcedureModel> searchResults;
  final String searchQuery;
  final bool isSearching;

  const HomeLoaded({
    required this.categories,
    required this.recentSavedProcedures,
    this.searchResults = const [],
    this.searchQuery = '',
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
    categories,
    recentSavedProcedures,
    searchResults,
    searchQuery,
    isSearching,
  ];

  HomeLoaded copyWith({
    List<CategoryModel>? categories,
    List<ProcedureModel>? recentSavedProcedures,
    List<ProcedureModel>? searchResults,
    String? searchQuery,
    bool? isSearching,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      recentSavedProcedures:
          recentSavedProcedures ?? this.recentSavedProcedures,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
