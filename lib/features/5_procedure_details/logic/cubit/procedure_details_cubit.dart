import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/sqflite_service.dart';
import '../../../3_home/data/models/procedure_model.dart';
import '../../../3_home/data/models/checklist_item_model.dart';

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
    emit(state.copyWith(isLoading: true));
    try {
      // Load procedure details
      final procedureMap = await _sqliteService.getProcedureById(procedureId);
      if (procedureMap == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Procedure not found',
        ));
        return;
      }

      final procedure = ProcedureModel.fromMap(procedureMap);

      // Load procedure steps
      final stepsMap = await _sqliteService.getProcedureSteps(procedureId);
      final steps = stepsMap.map((step) => StepModel.fromMap(step)).toList();

      // Load checklist items for each step
      final Map<int, List<ChecklistItemModel>> checklistItems = {};
      for (var step in steps) {
        final items =
            await _sqliteService.getChecklistItems(procedureId, step.id);
        checklistItems[step.id] =
            items.map((item) => ChecklistItemModel.fromMap(item)).toList();
      }

      // Load user progress if authenticated
      Map<String, dynamic>? userProgress;
      if (_userId != null) {
        userProgress =
            await _sqliteService.getUserProgress(_userId!, procedureId);
      }

      emit(state.copyWith(
        isLoading: false,
        procedure: procedure,
        steps: steps,
        checklistItems: checklistItems,
        completedSteps: userProgress != null
            ? List<int>.from(userProgress['completed_steps'] as List)
            : [],
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error loading procedure: $e',
      ));
    }
  }

  Future<void> toggleChecklistItem(int itemId, bool isCompleted) async {
    if (_userId == null) return;

    try {
      // Update checklist item completion status
      await _sqliteService.updateChecklistItemStatus(itemId, isCompleted);

      // Update state with new checklist items
      final updatedItems =
          Map<int, List<ChecklistItemModel>>.from(state.checklistItems);
      for (var stepId in updatedItems.keys) {
        updatedItems[stepId] = updatedItems[stepId]!.map((item) {
          if (item.id == itemId) {
            return item.copyWith(isCompleted: isCompleted);
          }
          return item;
        }).toList();
      }

      // Check if all required items are completed for any steps
      final completedSteps = List<int>.from(state.completedSteps);
      for (var step in state.steps) {
        final stepItems = updatedItems[step.id] ?? [];
        final allRequiredCompleted = stepItems
            .where((item) => item.isRequired)
            .every((item) => item.isCompleted);

        if (allRequiredCompleted && !completedSteps.contains(step.id)) {
          completedSteps.add(step.id);
        } else if (!allRequiredCompleted && completedSteps.contains(step.id)) {
          completedSteps.remove(step.id);
        }
      }

      // Update user progress
      await _sqliteService.updateUserProgress(
        _userId!,
        state.procedure!.id,
        completedSteps,
      );

      emit(state.copyWith(
        checklistItems: updatedItems,
        completedSteps: completedSteps,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error updating checklist item: $e',
      ));
    }
  }

  Future<void> toggleSaveStatus() async {
    if (_userId == null) return;
    // Implementation for saving/unsaving procedures
  }
}

class StepModel extends Equatable {
  final int id;
  final int procedureId;
  final String stepEn;
  final String rationalAr;
  final String? videoUrl;

  const StepModel({
    required this.id,
    required this.procedureId,
    required this.stepEn,
    required this.rationalAr,
    this.videoUrl,
  });

  factory StepModel.fromMap(Map<String, dynamic> map) {
    return StepModel(
      id: map['id'] as int,
      procedureId: map['procedure_id'] as int,
      stepEn: map['step_en'] as String,
      rationalAr: map['rational_ar'] as String,
      videoUrl: map['video_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, procedureId, stepEn, rationalAr, videoUrl];
}
