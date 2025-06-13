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
  final bool isViewed;
  final bool isSaved;

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
    this.isViewed = false,
    this.isSaved = false,
  });

  factory ProcedureModel.fromMap(Map<String, dynamic> map) {
    return ProcedureModel(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      categoryNameAr: map['category_name_ar'] as String,
      titleAr: map['title_ar'] as String,
      overviewAr: map['overview_ar'] as String,
      indicationsAr: List<String>.from(jsonDecode(map['indications_ar'])),
      contraindicationsAr: List<String>.from(
        jsonDecode(map['contraindications_ar']),
      ),
      complicationsAr: List<String>.from(jsonDecode(map['complications_ar'])),
      toolsAr: List<String>.from(jsonDecode(map['tools_ar'])),
      extraInfoAr: map['extra_info_ar'] as String,
      imageUrls: List<String>.from(jsonDecode(map['image_urls'])),
      isViewed: map['is_viewed'] == 1,
      isSaved: map['is_saved'] == 1,
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
      'is_viewed': isViewed ? 1 : 0,
      'is_saved': isSaved ? 1 : 0,
    };
  }

  ProcedureModel copyWith({
    int? id,
    int? categoryId,
    String? categoryNameAr,
    String? titleAr,
    String? overviewAr,
    List<String>? indicationsAr,
    List<String>? contraindicationsAr,
    List<String>? complicationsAr,
    List<String>? toolsAr,
    String? extraInfoAr,
    List<String>? imageUrls,
    bool? isViewed,
    bool? isSaved,
  }) {
    return ProcedureModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      titleAr: titleAr ?? this.titleAr,
      overviewAr: overviewAr ?? this.overviewAr,
      indicationsAr: indicationsAr ?? this.indicationsAr,
      contraindicationsAr: contraindicationsAr ?? this.contraindicationsAr,
      complicationsAr: complicationsAr ?? this.complicationsAr,
      toolsAr: toolsAr ?? this.toolsAr,
      extraInfoAr: extraInfoAr ?? this.extraInfoAr,
      imageUrls: imageUrls ?? this.imageUrls,
      isViewed: isViewed ?? this.isViewed,
      isSaved: isSaved ?? this.isSaved,
    );
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
    isViewed,
    isSaved,
  ];
}
