import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:tandur/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: '.env');
  // await OnboardingPrefs.reset();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AuthProvider.instance)],
      child: const TandurApp(),
    ),
  );
}

class TandurApp extends StatelessWidget {
  const TandurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      // CUKUP TULIS SATU BARIS INI:
      routerConfig: AppRouter.router,
    );
  }
}
