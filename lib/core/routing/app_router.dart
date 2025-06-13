import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/3_home/presentation/screens/home_screen.dart';
import '../../features/4_procedures_list/presentation/screens/procedures_list_screen.dart';
import '../../features/4_procedures_list/presentation/cubit/procedures_list_cubit.dart';

class AppRouter {
  static SharedPreferences? _prefs;

  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      // Continue without SharedPreferences
    }
  }

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: _guard,
    routes: [
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/saved-procedures');
                  break;
                case 2:
                  context.go('/settings');
                  break;
              }
            },
            selectedIndex: _calculateSelectedIndex(context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark),
                label: 'المحفوظات',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'الإعدادات',
              ),
            ],
          ),
        ),
        routes: [
          // Home route
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Nested routes under home
              GoRoute(
                path: 'procedures-list/:categoryId',
                builder: (context, state) => BlocProvider(
                  create: (context) => ProceduresListCubit(),
                  child: ProceduresListScreen(
                    categoryId: int.parse(state.pathParameters['categoryId']!),
                  ),
                ),
              ),
              GoRoute(
                path: 'procedure-details/:procedureId',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),

          // Saved procedures route
          GoRoute(
            path: '/saved-procedures',
            builder: (context, state) => const Placeholder(),
          ),

          // Settings route
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),
    ],
  );

  // Guard function to handle navigation based on auth state
  static String? _guard(BuildContext? context, GoRouterState state) {
    try {
      // Check if user has seen onboarding
      final hasSeenOnboarding = _prefs?.getBool('hasSeenOnboarding') ?? false;
      if (!hasSeenOnboarding && state.fullPath != '/onboarding') {
        return '/onboarding';
      }

      // Check if user is authenticated
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;
      final isAuthRoute = state.fullPath == '/login';
      final isOnboardingRoute = state.fullPath == '/onboarding';

      if (!isAuthenticated && !isAuthRoute && !isOnboardingRoute) {
        return '/login';
      }

      if (isAuthenticated && (isAuthRoute || isOnboardingRoute)) {
        return '/home';
      }

      return null;
    } catch (e) {
      print('Error in navigation guard: $e');
      // Default to onboarding in case of errors
      return '/onboarding';
    }
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).fullPath!;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/saved-procedures')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }
}

// Placeholder screens for unimplemented features
class ProcedureDetailsScreen extends StatelessWidget {
  final int procedureId;
  const ProcedureDetailsScreen({super.key, required this.procedureId});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SavedProceduresScreen extends StatelessWidget {
  const SavedProceduresScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}
