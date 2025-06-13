import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/firebase_service.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/procedure_model.dart';

// Home States
class HomeState extends Equatable {
  final List<CategoryModel> categories;
  final List<ProcedureModel> savedProcedures;
  final List<ProcedureModel> searchResults;
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
    List<ProcedureModel>? savedProcedures,
    List<ProcedureModel>? searchResults,
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
      final procedures = await _sqliteService.getProcedures();
      final categories = procedures
          .map((p) => CategoryModel(
                id: p['category_id'] as int,
                nameAr: p['category_name_ar'] as String,
              ))
          .toSet()
          .toList();

      // Get saved procedures if user is logged in
      List<ProcedureModel> savedProcedures = [];
      if (!isGuest) {
        final savedIds =
            await _firebaseService.getSavedProcedureIds(user.uid).first;

        for (var id in savedIds) {
          final proc = await _sqliteService.getProcedureById(id);
          if (proc != null) {
            savedProcedures.add(ProcedureModel.fromMap(proc));
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
      emit(state.copyWith(
        searchResults: results.map((p) => ProcedureModel.fromMap(p)).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'حدث خطأ في البحث: ${e.toString()}',
      ));
    }
  }
}
