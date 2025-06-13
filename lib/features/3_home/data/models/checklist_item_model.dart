import 'package:equatable/equatable.dart';

class ChecklistItemModel extends Equatable {
  final int id;
  final int procedureId;
  final int stepId;
  final String itemText;
  final bool isRequired;
  final bool isCompleted;

  const ChecklistItemModel({
    required this.id,
    required this.procedureId,
    required this.stepId,
    required this.itemText,
    required this.isRequired,
    this.isCompleted = false,
  });

  factory ChecklistItemModel.fromMap(Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: map['id'] as int,
      procedureId: map['procedure_id'] as int,
      stepId: map['step_id'] as int,
      itemText: map['item_text'] as String,
      isRequired: map['is_required'] == 1,
      isCompleted: map['is_completed'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'procedure_id': procedureId,
      'step_id': stepId,
      'item_text': itemText,
      'is_required': isRequired ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  ChecklistItemModel copyWith({
    int? id,
    int? procedureId,
    int? stepId,
    String? itemText,
    bool? isRequired,
    bool? isCompleted,
  }) {
    return ChecklistItemModel(
      id: id ?? this.id,
      procedureId: procedureId ?? this.procedureId,
      stepId: stepId ?? this.stepId,
      itemText: itemText ?? this.itemText,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        procedureId,
        stepId,
        itemText,
        isRequired,
        isCompleted,
      ];

  @override
  bool get stringify => true;
}
