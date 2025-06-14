import 'package:flutter/foundation.dart';
import '../database/sqflite_service.dart';

class SearchService {
  final SqliteService _sqliteService;

  SearchService(this._sqliteService);

  Future<List<Procedure>> searchProcedures(
    String query, {
    String? categoryFilter,
    List<Procedure>? savedProceduresOnly,
  }) async {
    if (query.isEmpty) return const [];

    // Get the procedures based on the context
    List<Procedure> procedures;
    if (savedProceduresOnly != null) {
      procedures = savedProceduresOnly;
    } else if (categoryFilter != null) {
      procedures = await _sqliteService.getProceduresByCategory(categoryFilter);
    } else {
      procedures = await _sqliteService.getAllProcedures();
    }

    // Split query into keywords
    final keywords = query.toLowerCase().split(' ')
      ..removeWhere((k) => k.isEmpty);

    // Score and filter procedures
    final scoredProcedures = procedures
        .map((procedure) {
          final score = _calculateRelevanceScore(procedure, keywords);
          return MapEntry(procedure, score);
        })
        .where((entry) => entry.value > 0)
        .toList();

    // Sort by score
    scoredProcedures.sort((a, b) => b.value.compareTo(a.value));

    // Return sorted procedures
    return scoredProcedures.map((e) => e.key).toList();
  }

  double _calculateRelevanceScore(Procedure procedure, List<String> keywords) {
    double score = 0;

    final name = procedure.name.toLowerCase();
    final category = procedure.category?.toLowerCase() ?? '';
    final description = procedure.description?.toLowerCase() ?? '';
    final steps = procedure.steps?.map((s) => s.toLowerCase()).join(' ') ?? '';
    final hints = procedure.hints?.map((h) => h.toLowerCase()).join(' ') ?? '';

    for (final keyword in keywords) {
      // Exact matches in name (highest weight)
      if (name == keyword) score += 10;
      if (name.contains(keyword)) score += 5;

      // Category matches
      if (category == keyword) score += 8;
      if (category.contains(keyword)) score += 4;

      // Description matches
      if (description.contains(keyword)) score += 3;

      // Steps matches
      if (steps.contains(keyword)) score += 2;

      // Hints matches
      if (hints.contains(keyword)) score += 1;

      // Partial word matches
      if (name.split(' ').any((word) => word.startsWith(keyword))) score += 2;
      if (category.split(' ').any((word) => word.startsWith(keyword)))
        score += 1.5;
    }

    // Bonus for matching multiple keywords
    if (keywords.length > 1) {
      final allKeywordsMatch = keywords.every((keyword) =>
          name.contains(keyword) ||
          category.contains(keyword) ||
          description.contains(keyword) ||
          steps.contains(keyword) ||
          hints.contains(keyword));
      if (allKeywordsMatch) score *= 1.5;
    }

    return score;
  }
}
