import 'package:flutter/material.dart';
import 'package:tandur/features/home/home_page.dart';
import 'package:tandur/features/splash/splash_screen.dart';
import 'package:tandur/features/welcome/welcome_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String home = '/home';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
