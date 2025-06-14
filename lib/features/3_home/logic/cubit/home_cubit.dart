import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/firebase_service.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/services/search_service.dart';
import '../../data/models/category_model.dart';

// Home States
class HomeState extends Equatable {
  final List<CategoryModel> categories;
  final List<Procedure> savedProcedures;
  final List<Procedure> searchResults;
  final bool isGuest;
  final String? userName;
  final bool isLoading;
  final String? error;
  final bool isSearching;

  const HomeState({
    this.categories = const [],
    this.savedProcedures = const [],
    this.searchResults = const [],
    this.isGuest = false,
    this.userName,
    this.isLoading = false,
    this.error,
    this.isSearching = false,
  });

  HomeState copyWith({
    List<CategoryModel>? categories,
    List<Procedure>? savedProcedures,
    List<Procedure>? searchResults,
    bool? isGuest,
    String? userName,
    bool? isLoading,
    String? error,
    bool? isSearching,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      savedProcedures: savedProcedures ?? this.savedProcedures,
      searchResults: searchResults ?? this.searchResults,
      isGuest: isGuest ?? this.isGuest,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        savedProcedures,
        searchResults,
        isGuest,
        userName,
        isLoading,
        error,
        isSearching,
      ];
}

// Home Cubit
class HomeCubit extends Cubit<HomeState> {
  final _firebaseService = FirebaseService();
  final SqliteService _sqliteService = SqliteService();
  late final SearchService _searchService;

  HomeCubit() : super(const HomeState()) {
    _searchService = SearchService(_sqliteService);
  }

  Future<void> loadHomePageData() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Load user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');
      final isGuest = prefs.getBool('is_guest') ?? false;

      // Get categories and count procedures in each category
      final procedures = await _sqliteService.getAllProcedures();
      final categoriesMap = <String, CategoryModel>{};

      // Group procedures by category and count them
      for (var p in procedures) {
        if (p.category != null) {
          final category = categoriesMap[p.category!];
          if (category == null) {
            categoriesMap[p.category!] = CategoryModel(
              nameAr: p.category!,
              iconName: p.categoryIcon,
              proceduresCount: 1,
              id: 1,
            );
          } else {
            categoriesMap[p.category!] = CategoryModel(
              nameAr: category.nameAr,
              iconName: category.iconName,
              proceduresCount: (category.proceduresCount ?? 0) + 1,
              id: 1,
            );
          }
        }
      }

      // Get saved procedures
      final savedProcedures = await _sqliteService.getSavedProcedures();

      emit(state.copyWith(
        categories: categoriesMap.values.toList(),
        savedProcedures: savedProcedures.take(3).toList(),
        isLoading: false,
        userName: userName,
        isGuest: isGuest,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> searchProcedures(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    try {
      emit(state.copyWith(isSearching: true));
      final results = await _searchService.searchProcedures(query);
      emit(state.copyWith(
        searchResults: results,
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
