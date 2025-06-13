import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/firebase_service.dart';

// Import screens
import '../../features/1_onboarding/ui/screens/onboarding_screen.dart';
import '../../features/2_auth/ui/screens/login_screen.dart';
import '../../features/3_home/ui/screens/home_screen.dart';
import '../../features/4_procedures_list/ui/screens/procedures_list_screen.dart';
import '../../features/5_procedure_details/ui/screens/procedure_details_screen.dart';
import '../../features/6_saved_procedures/ui/screens/saved_procedures_screen.dart';
import '../../features/7_settings/ui/screens/settings_screen.dart';
import '../../features/0_splash/ui/screens/splash_screen.dart';

class AppRouter {
  static final _firebaseService = FirebaseService();
  static late final SharedPreferences _prefs;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) async {
          // Wait for initialization
          if (!_isInitialized) {
            await init();
            return null;
          }

          final hasSeenOnboarding =
              _prefs.getBool('hasSeenOnboarding') ?? false;
          if (!hasSeenOnboarding) {
            return '/onboarding';
          }

          if (!_firebaseService.isLoggedIn) {
            return '/login';
          }

          return '/home';
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/procedures-list/:categoryName',
        builder: (context, state) {
          final categoryName = state.pathParameters['categoryName']!;
          return ProceduresListScreen(categoryName: categoryName);
        },
      ),
      GoRoute(
        path: '/procedure-details/:procedureId',
        builder: (context, state) {
          final procedureId = int.parse(state.pathParameters['procedureId']!);
          final gradient = state.extra as Gradient?;
          return ProcedureDetailsScreen(
            procedureId: procedureId,
            gradient: gradient,
          );
        },
      ),
      GoRoute(
        path: '/saved-procedures',
        builder: (context, state) => const SavedProceduresScreen(),
        redirect: (context, state) async {
          await init();
          if (!_firebaseService.isLoggedIn) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  // Navigation helpers
  static void goToHome(BuildContext context) => context.go('/home');
  static void goToLogin(BuildContext context) => context.go('/login');
  static void goToProceduresList(BuildContext context, String categoryName) =>
      context.push('/procedures-list/$categoryName');
  static void goToProcedureDetails(BuildContext context, int procedureId,
          {Object? extra}) =>
      context.push('/procedure-details/$procedureId', extra: extra);
  static void goToSavedProcedures(BuildContext context) =>
      context.go('/saved-procedures');
  static void goToSettings(BuildContext context) => context.go('/settings');
}
