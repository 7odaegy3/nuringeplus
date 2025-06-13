import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/1_onboarding/ui/screens/onboarding_screen.dart';
import '../../features/2_auth/presentation/screens/login_screen.dart';
import '../../features/3_home/ui/screens/home_screen.dart';
import '../../features/4_procedures_list/ui/screens/procedures_list_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: _guard,
    routes: [
      // Initial route
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // Onboarding route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth route
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          // Home route
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Nested routes under home
              GoRoute(
                path: 'procedures-list/:categoryId',
                builder: (context, state) => ProceduresListScreen(
                  categoryId: int.parse(state.pathParameters['categoryId']!),
                ),
              ),
              GoRoute(
                path: 'procedure-details/:procedureId',
                builder: (context, state) => ProcedureDetailsScreen(
                  procedureId: int.parse(state.pathParameters['procedureId']!),
                ),
              ),
            ],
          ),

          // Saved procedures route
          GoRoute(
            path: '/saved-procedures',
            builder: (context, state) => const SavedProceduresScreen(),
          ),

          // Settings route
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
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
      if (!hasSeenOnboarding &&
          !state.matchedLocation.startsWith('/onboarding')) {
        return '/onboarding';
      }

      // Check if user is authenticated
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login');
      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');

      if (!isAuthenticated && !isAuthRoute && !isOnboardingRoute) {
        return '/login';
      }

      if (isAuthenticated) {
        if (isAuthRoute || isOnboardingRoute) {
          return '/home';
        }
        if (state.matchedLocation == '/') {
          return '/home';
        }
      }

      return null;
    } catch (e) {
      print('Error in navigation guard: $e');
      return '/onboarding';
    }
  }
}

// Temporary placeholder screens for unimplemented features
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

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/saved-procedures')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }
}
