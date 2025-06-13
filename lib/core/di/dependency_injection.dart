import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/firebase_service.dart';
import '../database/sqflite_service.dart';
import '../routing/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/3_home/data/repos/home_repo.dart';

class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  static DependencyInjection get instance => _instance;

  late HomeRepo homeRepo;
  late FirebaseService firebaseService;
  late FirebaseAuth firebaseAuth;

  DependencyInjection._internal();

  Future<void> init() async {
    try {
      // Initialize SharedPreferences for AppRouter
      await AppRouter.init();

      // Initialize SQLite database
      await SqfliteService.instance.init();

      // Initialize services
      firebaseService = FirebaseService.instance;
      firebaseAuth = FirebaseAuth.instance;

      // Initialize repositories
      homeRepo = HomeRepo();
    } catch (e) {
      print('Error initializing dependencies: $e');
      rethrow;
    }
  }

  // Service Getters
  static SqfliteService get sqfliteService => SqfliteService.instance;
}
