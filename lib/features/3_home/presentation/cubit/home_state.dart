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

class HomeSuccess extends HomeState {
  final List<CategoryModel> categories;
  final List<ProcedureModel> recentSavedProcedures;
  final bool isUserLoggedIn;
  final String? userName;
  final List<ProcedureModel> searchResults;
  final bool isSearching;

  const HomeSuccess({
    required this.categories,
    required this.recentSavedProcedures,
    required this.isUserLoggedIn,
    this.userName,
    this.searchResults = const [],
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
    categories,
    recentSavedProcedures,
    isUserLoggedIn,
    userName,
    searchResults,
    isSearching,
  ];

  HomeSuccess copyWith({
    List<CategoryModel>? categories,
    List<ProcedureModel>? recentSavedProcedures,
    bool? isUserLoggedIn,
    String? userName,
    List<ProcedureModel>? searchResults,
    bool? isSearching,
  }) {
    return HomeSuccess(
      categories: categories ?? this.categories,
      recentSavedProcedures:
          recentSavedProcedures ?? this.recentSavedProcedures,
      isUserLoggedIn: isUserLoggedIn ?? this.isUserLoggedIn,
      userName: userName ?? this.userName,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
