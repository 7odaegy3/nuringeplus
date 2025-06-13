import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/firebase_service.dart';
import '../../../../core/database/sqflite_service.dart';
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

  const HomeState({
    this.categories = const [],
    this.savedProcedures = const [],
    this.searchResults = const [],
    this.isGuest = false,
    this.userName,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<CategoryModel>? categories,
    List<Procedure>? savedProcedures,
    List<Procedure>? searchResults,
    bool? isGuest,
    String? userName,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      savedProcedures: savedProcedures ?? this.savedProcedures,
      searchResults: searchResults ?? this.searchResults,
      isGuest: isGuest ?? this.isGuest,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
      ];
}

// Home Cubit
class HomeCubit extends Cubit<HomeState> {
  final _firebaseService = FirebaseService();
  final _sqliteService = SqliteService();

  HomeCubit() : super(const HomeState());

  Future<void> loadHomePageData() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Get user info
      final user = _firebaseService.currentUser;
      final isGuest = user == null;
      final userName = user?.displayName;

      // Get categories from SQLite
      final procedures = await _sqliteService.getAllProcedures();
      final categoriesMap = <String, CategoryModel>{};
      for (var p in procedures) {
        if (p.category != null) {
          // Assuming a procedure's category name can be used as a unique key for the category.
          // You might need a more robust way to handle category IDs if they are not just names.
          categoriesMap[p.category!] = CategoryModel(
              id: p.id, nameAr: p.category!, iconName: p.categoryIcon);
        }
      }
      final categories = categoriesMap.values.toList();

      // Get saved procedures if user is logged in
      List<Procedure> savedProcedures = [];
      if (!isGuest) {
        final savedIds =
            await _firebaseService.getSavedProcedureIds(user.uid).first;

        for (var id in savedIds) {
          final proc = await _sqliteService.getProcedureById(id);
          if (proc != null) {
            savedProcedures.add(proc);
          }
        }
      }

      emit(state.copyWith(
        categories: categories,
        savedProcedures: savedProcedures,
        isGuest: isGuest,
        userName: userName,
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
      emit(state.copyWith(searchResults: []));
      return;
    }

    try {
      final results = await _sqliteService.searchProcedures(query);
      emit(state.copyWith(searchResults: results));
    } catch (e) {
      emit(state.copyWith(
        error: 'حدث خطأ في البحث: ${e.toString()}',
      ));
    }
  }
}
