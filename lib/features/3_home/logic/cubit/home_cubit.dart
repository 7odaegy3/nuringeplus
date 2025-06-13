import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/firebase_service.dart';
import '../../data/repos/home_repo.dart';
import '../state/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;
  final FirebaseService _firebaseService;
  final FirebaseAuth _auth;

  HomeCubit({
    required HomeRepo homeRepo,
    required FirebaseService firebaseService,
    required FirebaseAuth auth,
  }) : _homeRepo = homeRepo,
       _firebaseService = firebaseService,
       _auth = auth,
       super(HomeInitial());

  Future<void> loadHomePageData() async {
    try {
      emit(HomeLoading());

      // Get categories
      final categories = await _homeRepo.getCategories();

      // Get saved procedures if user is logged in
      List<int> savedProcedureIds = [];
      if (_auth.currentUser != null) {
        savedProcedureIds = await _firebaseService.getSavedProcedureIds(
          _auth.currentUser!.uid,
        );
      }

      // Get recent saved procedures
      final recentSavedProcedures = await _homeRepo.getRecentSavedProcedures(
        savedProcedureIds,
      );

      emit(
        HomeLoaded(
          categories: categories,
          recentSavedProcedures: recentSavedProcedures,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> searchProcedures(String query) async {
    try {
      // Get current state
      final currentState = state;
      if (currentState is! HomeLoaded) return;

      // Update state to show we're searching
      emit(
        currentState.copyWith(
          searchQuery: query,
          isSearching: query.isNotEmpty,
        ),
      );

      if (query.isEmpty) {
        emit(currentState.copyWith(searchResults: [], isSearching: false));
        return;
      }

      // Perform search
      final results = await _homeRepo.searchProcedures(query);

      // Update state with results
      emit(currentState.copyWith(searchResults: results, isSearching: true));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
