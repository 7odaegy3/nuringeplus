import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String nameAr;
  final String? iconName;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    this.iconName,
    required int proceduresCount,
  });

  @override
  List<Object?> get props => [id, nameAr, iconName];

  @override
  bool get stringify => true;

  get proceduresCount => null;
}
