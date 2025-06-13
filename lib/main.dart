import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/theming/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize SharedPreferences
    await AppRouter.init();

    runApp(const NursingPlusApp());
  } catch (e) {
    debugPrint('Error during initialization: $e');
    // You might want to show an error screen here
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('حدث خطأ أثناء تشغيل التطبيق'),
        ),
      ),
    ));
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
          routerConfig: AppRouter.router,
          locale: const Locale('ar', 'EG'), // Set Arabic as default locale
          builder: (context, child) {
            // Ensure RTL for Arabic
            return Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                // Ensure proper text scaling
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
