import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/sqflite_service.dart';

part 'procedure_details_state.dart';

class ProcedureDetailsCubit extends Cubit<ProcedureDetailsState> {
  final SqliteService _sqliteService = SqliteService();
  String? _userId;

  ProcedureDetailsCubit() : super(const ProcedureDetailsState());

  void setUserId(String? userId) {
    _userId = userId;
    emit(state.copyWith(isGuest: userId == null));
  }

  Future<void> loadProcedure(int procedureId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final procedure = await _sqliteService.getProcedureById(procedureId);

      // Here you could potentially load saved status based on _userId

      emit(state.copyWith(
        isLoading: false,
        procedure: procedure,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'An error occurred: $e',
      ));
    }
  }

  Future<void> toggleSaveStatus() async {
    if (_userId == null) return;
    // This is where you would implement logic to save/unsave a procedure
    // for a specific user, likely interacting with another table or service.
    // For now, we just toggle the state.
    emit(state.copyWith(isSaved: !state.isSaved));
  }
}
