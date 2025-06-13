import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String nameAr;

  const CategoryModel({
    required this.id,
    required this.nameAr,
  });

  @override
  List<Object?> get props => [id, nameAr];

  @override
  bool get stringify => true;
}
