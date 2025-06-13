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
  final String? videoUrl;
  final bool isCompleted;
  final List<int> completedSteps;
  final String? lastAccessed;

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
    this.videoUrl,
    this.isCompleted = false,
    this.completedSteps = const [],
    this.lastAccessed,
  });

  factory ProcedureModel.fromMap(Map<String, dynamic> map) {
    return ProcedureModel(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      categoryNameAr: map['category_name_ar'] as String,
      titleAr: map['title_ar'] as String,
      overviewAr: map['overview_ar'] as String,
      indicationsAr:
          List<String>.from(jsonDecode(map['indications_ar'] as String)),
      contraindicationsAr:
          List<String>.from(jsonDecode(map['contraindications_ar'] as String)),
      complicationsAr:
          List<String>.from(jsonDecode(map['complications_ar'] as String)),
      toolsAr: List<String>.from(jsonDecode(map['tools_ar'] as String)),
      extraInfoAr: map['extra_info_ar'] as String,
      imageUrls: List<String>.from(jsonDecode(map['image_urls'] as String)),
      videoUrl: map['video_url'] != null
          ? jsonDecode(map['video_url'] as String)
          : null,
      isCompleted: map['is_completed'] as bool? ?? false,
      completedSteps: map['completed_steps'] != null
          ? List<int>.from(jsonDecode(map['completed_steps'] as String))
          : const [],
      lastAccessed: map['last_accessed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_accessed'] as int)
              .toIso8601String()
          : null,
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
      'video_url': videoUrl != null ? jsonEncode(videoUrl) : null,
      'is_completed': isCompleted,
      'completed_steps': jsonEncode(completedSteps),
      'last_accessed': lastAccessed != null
          ? DateTime.parse(lastAccessed!).millisecondsSinceEpoch
          : null,
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
    String? videoUrl,
    bool? isCompleted,
    List<int>? completedSteps,
    String? lastAccessed,
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
      videoUrl: videoUrl ?? this.videoUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      completedSteps: completedSteps ?? this.completedSteps,
      lastAccessed: lastAccessed ?? this.lastAccessed,
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
        videoUrl,
        isCompleted,
        completedSteps,
        lastAccessed,
      ];

  @override
  bool get stringify => true;
}
