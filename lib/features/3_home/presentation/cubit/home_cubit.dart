import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/procedure_model.dart';
import '../../data/repositories/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;

  HomeCubit({HomeRepo? homeRepo})
    : _homeRepo = homeRepo ?? HomeRepo(),
      super(HomeInitial());

  Future<void> loadHomePageData() async {
    try {
      emit(HomeLoading());

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null && !user.isAnonymous;

      // Get categories
      final categories = await _homeRepo.getCategories();

      // Get recent saved procedures if user is logged in
      final List<ProcedureModel> recentSavedProcedures = isLoggedIn
          ? await _homeRepo.getRecentSavedProcedures()
          : [];

      emit(
        HomeSuccess(
          categories: categories,
          recentSavedProcedures: recentSavedProcedures,
          isUserLoggedIn: isLoggedIn,
          userName: isLoggedIn ? _extractFirstName(user!.displayName) : null,
        ),
      );
    } catch (e) {
      emit(HomeFailure(e.toString()));
    }
  }

  Future<void> searchProcedures(String query) async {
    try {
      final currentState = state;
      if (currentState is HomeSuccess) {
        // If query is empty, clear search results
        if (query.isEmpty) {
          emit(
            currentState.copyWith(
              searchResults: const <ProcedureModel>[],
              isSearching: false,
            ),
          );
          return;
        }

        // Show loading state while keeping current data
        emit(currentState.copyWith(isSearching: true));

        // Perform search
        final results = await _homeRepo.searchProcedures(query);

        // Update state with search results
        emit(currentState.copyWith(searchResults: results, isSearching: false));
      }
    } catch (e) {
      emit(HomeFailure(e.toString()));
    }
  }

  Future<void> loadProceduresByCategory(int categoryId) async {
    try {
      final currentState = state;
      if (currentState is HomeSuccess) {
        // Show loading state while keeping current data
        emit(currentState.copyWith(isSearching: true));

        // Get procedures for the selected category
        final procedures = await _homeRepo.getProceduresByCategory(categoryId);

        // Update state with category procedures
        emit(
          currentState.copyWith(searchResults: procedures, isSearching: false),
        );
      }
    } catch (e) {
      emit(HomeFailure(e.toString()));
    }
  }

  String? _extractFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return null;
    return fullName.split(' ').first;
  }
}
