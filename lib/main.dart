import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TandurApp());
}

class TandurApp extends StatelessWidget {
  const TandurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tandur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
