import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String nameAr;
  final List<String> gradientColors;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.gradientColors,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int,
      nameAr: map['category_name_ar'] as String,
      // Default gradient colors if not provided
      gradientColors: const ['#9C27B0', '#7B1FA2'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'category_name_ar': nameAr};
  }

  @override
  List<Object?> get props => [id, nameAr, gradientColors];
}
