import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SharedPreferences.getInstance();
    await AppRouter.init();

    runApp(const NursingPlusApp());
  } catch (e) {
    debugPrint('Error during initialization: $e');
    rethrow;
  }
}

class NursingPlusApp extends StatelessWidget {
  const NursingPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X dimensions as base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Nursing Plus',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          locale: const Locale('ar', 'EG'), // Set Arabic as default locale
          builder: (context, child) {
            // Ensure RTL for Arabic
            return Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                // Ensure proper text scaling
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
