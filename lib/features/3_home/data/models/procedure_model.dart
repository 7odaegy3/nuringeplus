import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProcedureModel extends Equatable {
  final int id;
  final int categoryId;
  final String categoryNameAr;
  final String titleAr;
  final String overviewAr;
  final List<String> indicationsAr;
  final List<String> contraindicationsAr;
  final List<String> complicationsAr;
  final List<String> toolsAr;
  final String extraInfoAr;
  final List<String> imageUrls;

  const ProcedureModel({
    required this.id,
    required this.categoryId,
    required this.categoryNameAr,
    required this.titleAr,
    required this.overviewAr,
    required this.indicationsAr,
    required this.contraindicationsAr,
    required this.complicationsAr,
    required this.toolsAr,
    required this.extraInfoAr,
    required this.imageUrls,
  });

  factory ProcedureModel.fromMap(Map<String, dynamic> map) {
    return ProcedureModel(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      categoryNameAr: map['category_name_ar'] as String,
      titleAr: map['title_ar'] as String,
      overviewAr: map['overview_ar'] as String,
      indicationsAr: List<String>.from(
        jsonDecode(map['indications_ar'] as String),
      ),
      contraindicationsAr: List<String>.from(
        jsonDecode(map['contraindications_ar'] as String),
      ),
      complicationsAr: List<String>.from(
        jsonDecode(map['complications_ar'] as String),
      ),
      toolsAr: List<String>.from(jsonDecode(map['tools_ar'] as String)),
      extraInfoAr: map['extra_info_ar'] as String,
      imageUrls: List<String>.from(jsonDecode(map['image_urls'] as String)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name_ar': categoryNameAr,
      'title_ar': titleAr,
      'overview_ar': overviewAr,
      'indications_ar': jsonEncode(indicationsAr),
      'contraindications_ar': jsonEncode(contraindicationsAr),
      'complications_ar': jsonEncode(complicationsAr),
      'tools_ar': jsonEncode(toolsAr),
      'extra_info_ar': extraInfoAr,
      'image_urls': jsonEncode(imageUrls),
    };
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    categoryNameAr,
    titleAr,
    overviewAr,
    indicationsAr,
    contraindicationsAr,
    complicationsAr,
    toolsAr,
    extraInfoAr,
    imageUrls,
  ];
}
