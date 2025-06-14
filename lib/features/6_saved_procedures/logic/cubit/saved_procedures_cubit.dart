import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/search_service.dart';
import 'saved_procedures_state.dart';

class SavedProceduresCubit extends Cubit<SavedProceduresState> {
  final SqliteService _sqliteService = SqliteService();
  final FirebaseService _firebaseService = FirebaseService();
  late final SearchService _searchService;
  StreamSubscription? _savedProceduresSubscription;

  SavedProceduresCubit() : super(const SavedProceduresState()) {
    _searchService = SearchService(_sqliteService);
    // Listen to changes in Firebase
    _savedProceduresSubscription =
        _firebaseService.savedProceduresStream().listen((procedureIds) {
      if (procedureIds.isNotEmpty) {
        _syncFromFirebase(procedureIds);
      }
    });
  }

  @override
  Future<void> close() {
    _savedProceduresSubscription?.cancel();
    return super.close();
  }

  Future<void> loadSavedProcedures() async {
    emit(state.copyWith(isLoading: true));
    try {
      // First load from local database
      final procedures = await _sqliteService.getSavedProcedures();
      emit(state.copyWith(
        procedures: procedures,
        isLoading: false,
      ));

      // Then check Firebase for any updates
      final firebaseProcedureIds =
          await _firebaseService.getSavedProcedureIds();
      if (firebaseProcedureIds.isNotEmpty) {
        await _syncFromFirebase(firebaseProcedureIds);
      } else {
        // If no data in Firebase, sync local data to Firebase
        await _syncToFirebase();
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _syncFromFirebase(List<int> procedureIds) async {
    try {
      // Clear existing saved procedures
      final currentSaved = await _sqliteService.getSavedProcedures();
      for (var procedure in currentSaved) {
        await _sqliteService.unsaveProcedure(procedure.id);
      }

      // Save new procedures from Firebase
      for (var id in procedureIds) {
        await _sqliteService.saveProcedure(id);
      }

      // Reload procedures
      final procedures = await _sqliteService.getSavedProcedures();
      emit(state.copyWith(procedures: procedures));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _syncToFirebase() async {
    try {
      final procedures = await _sqliteService.getSavedProcedures();
      final procedureIds = procedures.map((p) => p.id).toList();
      await _firebaseService.syncSavedProcedures(procedureIds);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> searchSavedProcedures(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(
        searchResults: [],
        lastSearchQuery: null,
      ));
      return;
    }

    try {
      emit(state.copyWith(isSearching: true));
      final results = await _searchService.searchProcedures(
        query,
        savedProceduresOnly: state.procedures,
      );
      emit(state.copyWith(
        searchResults: results,
        lastSearchQuery: query,
        isSearching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isSearching: false,
      ));
    }
  }

  Future<void> toggleSaveProcedure(Procedure procedure) async {
    try {
      final isSaved = await _sqliteService.isProcedureSaved(procedure.id);
      if (isSaved) {
        // Immediately update UI before database operations
        final updatedProcedures =
            state.procedures.where((p) => p.id != procedure.id).toList();
        final updatedSearchResults =
            state.searchResults.where((p) => p.id != procedure.id).toList();

        emit(state.copyWith(
          procedures: updatedProcedures,
          searchResults: updatedSearchResults,
        ));

        // Then perform database operations
        await _sqliteService.unsaveProcedure(procedure.id);
        await _syncToFirebase();
      } else {
        await _sqliteService.saveProcedure(procedure.id);
        // Reload procedures and sync with Firebase
        final procedures = await _sqliteService.getSavedProcedures();

        // Update search results if there's an active search
        List<Procedure> searchResults = state.searchResults;
        if (searchResults.isNotEmpty) {
          searchResults = await _searchService.searchProcedures(
            state.lastSearchQuery ?? '',
            savedProceduresOnly: procedures,
          );
        }

        emit(state.copyWith(
          procedures: procedures,
          searchResults: searchResults,
        ));
        await _syncToFirebase();
      }
    } catch (e) {
      // If there's an error, reload the actual state from database
      final procedures = await _sqliteService.getSavedProcedures();

      // Also update search results if there's an active search
      List<Procedure> searchResults = state.searchResults;
      if (searchResults.isNotEmpty && state.lastSearchQuery != null) {
        searchResults = await _searchService.searchProcedures(
          state.lastSearchQuery!,
          savedProceduresOnly: procedures,
        );
      }

      emit(state.copyWith(
        procedures: procedures,
        searchResults: searchResults,
        error: e.toString(),
      ));
    }
  }
}
