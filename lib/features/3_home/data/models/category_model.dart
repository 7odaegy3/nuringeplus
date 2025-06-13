import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String nameAr;
  final String iconName;
  final List<String> gradientColors;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.iconName,
    required this.gradientColors,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int,
      nameAr: map['name_ar'] as String,
      iconName: map['icon_name'] as String,
      gradientColors: List<String>.from(map['gradient_colors']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_ar': nameAr,
      'icon_name': iconName,
      'gradient_colors': gradientColors,
    };
  }

  @override
  List<Object?> get props => [id, nameAr, iconName, gradientColors];
}
