import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/firebase_service.dart';
import '../database/sqflite_service.dart';
import '../routing/app_router.dart';

class DependencyInjection {
  static final FirebaseService _firebaseService = FirebaseService();
  static final SqfliteService _sqfliteService = SqfliteService();

  static Future<void> init() async {
    try {
      // Initialize SharedPreferences for AppRouter
      await AppRouter.init();

      // Initialize SQLite database
      await _sqfliteService.database;
    } catch (e) {
      print('Error initializing dependencies: $e');
      // Continue even if some dependencies fail
    }
  }

  // Service Getters
  static FirebaseService get firebaseService => _firebaseService;
  static SqfliteService get sqfliteService => _sqfliteService;
}
