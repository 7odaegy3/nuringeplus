import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/dependency_injection.dart';
import 'core/routing/app_router.dart';
import 'core/theming/app_theme.dart';
import 'features/3_home/logic/cubit/home_cubit.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize dependencies
    await DependencyInjection.instance.init();

    runApp(const NursingPlusApp());
  } catch (e) {
    print('Error initializing app: $e');
    // Run the app even if initialization fails
    runApp(const NursingPlusApp());
  }
}

class NursingPlusApp extends StatelessWidget {
  const NursingPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => HomeCubit(
                homeRepo: DependencyInjection.instance.homeRepo,
                firebaseService: DependencyInjection.instance.firebaseService,
                auth: DependencyInjection.instance.firebaseAuth,
              )..loadHomePageData(),
            ),
          ],
          child: MaterialApp.router(
            title: 'Nursing Plus',
            theme: AppTheme.light,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar', 'EG'),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
          ),
        );
      },
    );
  }
}
