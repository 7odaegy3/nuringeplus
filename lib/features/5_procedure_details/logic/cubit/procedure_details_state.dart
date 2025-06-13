part of 'procedure_details_cubit.dart';

class ProcedureDetailsState extends Equatable {
  final bool isLoading;
  final Procedure? procedure;
  final String? error;
  final bool isGuest;
  final bool isSaved;

  const ProcedureDetailsState({
    this.isLoading = false,
    this.procedure,
    this.error,
    this.isGuest = true,
    this.isSaved = false,
  });

  ProcedureDetailsState copyWith({
    bool? isLoading,
    Procedure? procedure,
    String? error,
    bool? isGuest,
    bool? isSaved,
    bool clearError = false,
  }) {
    return ProcedureDetailsState(
      isLoading: isLoading ?? this.isLoading,
      procedure: procedure ?? this.procedure,
      error: clearError ? null : error ?? this.error,
      isGuest: isGuest ?? this.isGuest,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        procedure,
        error,
        isGuest,
        isSaved,
      ];
}
