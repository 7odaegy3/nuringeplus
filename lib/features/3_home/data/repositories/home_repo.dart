import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/api/firebase_service.dart';
import '../../../../core/database/sqflite_service.dart';
import '../models/category_model.dart';
import '../models/procedure_model.dart';

class HomeRepo {
  final FirebaseService _firebaseService;
  final SqfliteService _sqfliteService;

  // Singleton pattern
  static final HomeRepo _instance = HomeRepo._internal();
  factory HomeRepo() => _instance;

  HomeRepo._internal()
    : _firebaseService = FirebaseService(),
      _sqfliteService = SqfliteService();

  // Get categories from SQLite
  Future<List<CategoryModel>> getCategories() async {
    try {
      final db = await _sqfliteService.database;
      final results = await db.rawQuery('''
        SELECT DISTINCT category_id as id, category_name_ar
        FROM procedures
        ORDER BY category_id
      ''');

      return results.map((map) => CategoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Get recent saved procedures
  Future<List<ProcedureModel>> getRecentSavedProcedures({int limit = 3}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      // Get saved procedure IDs from Firebase
      final savedIds = await _firebaseService
          .getSavedProcedureIds(user.uid)
          .first;

      if (savedIds.isEmpty) {
        return [];
      }

      // Get procedure details from SQLite
      final db = await _sqfliteService.database;
      final results = await db.query(
        'procedures',
        where: 'id IN (${savedIds.take(limit).map((_) => '?').join(', ')})',
        whereArgs: savedIds.take(limit).toList(),
      );

      return results.map((map) => ProcedureModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent saved procedures: $e');
    }
  }

  // Search procedures
  Future<List<ProcedureModel>> searchProcedures(String query) async {
    try {
      final db = await _sqfliteService.database;
      final results = await db.query(
        'procedures',
        where: 'title_ar LIKE ? OR overview_ar LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );

      return results.map((map) => ProcedureModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search procedures: $e');
    }
  }

  // Get procedures by category
  Future<List<ProcedureModel>> getProceduresByCategory(int categoryId) async {
    try {
      final db = await _sqfliteService.database;
      final results = await db.query(
        'procedures',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );

      return results.map((map) => ProcedureModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch procedures by category: $e');
    }
  }
}
