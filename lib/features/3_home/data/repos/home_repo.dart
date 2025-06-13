import 'package:sqflite/sqflite.dart';
import '../../../../core/database/sqflite_service.dart';
import '../models/category_model.dart';
import '../models/procedure_model.dart';

class HomeRepo {
  final Database _db;

  HomeRepo() : _db = SqfliteService.instance.database;

  Future<List<CategoryModel>> getCategories() async {
    final List<Map<String, dynamic>> maps = await _db.query('categories');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<List<ProcedureModel>> getRecentSavedProcedures(
    List<int> savedIds, {
    int limit = 3,
  }) async {
    if (savedIds.isEmpty) return [];

    final List<Map<String, dynamic>> maps = await _db.query(
      'procedures',
      where: 'id IN (${List.filled(savedIds.length, '?').join(',')})',
      whereArgs: savedIds,
      limit: limit,
    );

    return maps.map((map) => ProcedureModel.fromMap(map)).toList();
  }

  Future<List<ProcedureModel>> searchProcedures(String query) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'procedures',
      where: 'title_ar LIKE ? OR overview_ar LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((map) => ProcedureModel.fromMap(map)).toList();
  }

  Future<List<ProcedureModel>> getProceduresByCategory(int categoryId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'procedures',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );

    return maps.map((map) => ProcedureModel.fromMap(map)).toList();
  }
}
