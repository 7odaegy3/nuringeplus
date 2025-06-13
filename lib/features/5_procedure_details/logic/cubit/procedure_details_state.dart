part of 'procedure_details_cubit.dart';

class ProcedureDetailsState extends Equatable {
  final bool isLoading;
  final ProcedureModel? procedure;
  final List<StepModel> steps;
  final Map<int, List<ChecklistItemModel>> checklistItems;
  final List<int> completedSteps;
  final String? error;
  final bool isGuest;
  final bool isSaved;

  const ProcedureDetailsState({
    this.isLoading = false,
    this.procedure,
    this.steps = const [],
    this.checklistItems = const {},
    this.completedSteps = const [],
    this.error,
    this.isGuest = true,
    this.isSaved = false,
  });

  ProcedureDetailsState copyWith({
    bool? isLoading,
    ProcedureModel? procedure,
    List<StepModel>? steps,
    Map<int, List<ChecklistItemModel>>? checklistItems,
    List<int>? completedSteps,
    String? error,
    bool? isGuest,
    bool? isSaved,
  }) {
    return ProcedureDetailsState(
      isLoading: isLoading ?? this.isLoading,
      procedure: procedure ?? this.procedure,
      steps: steps ?? this.steps,
      checklistItems: checklistItems ?? this.checklistItems,
      completedSteps: completedSteps ?? this.completedSteps,
      error: error,
      isGuest: isGuest ?? this.isGuest,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        procedure,
        steps,
        checklistItems,
        completedSteps,
        error,
        isGuest,
        isSaved,
      ];
}
