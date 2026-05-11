import 'package:go_router/go_router.dart';
import 'package:tandur/core/widgets/app_shell.dart';
import 'package:tandur/features/home/home_page.dart';
import 'package:tandur/features/profile/profile_screen.dart';
import 'package:tandur/features/splash/splash_screen.dart';
import 'package:tandur/features/welcome/welcome_screen.dart';

class AppRoutes {
  static const String splash = 'splash';
  static const String welcome = 'welcome';
  static const String home = 'home';
  static const String profile = 'profile';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.welcome,
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child, location: state.uri.path);
        },
        routes: [
          GoRoute(
            name: AppRoutes.home,
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            name: AppRoutes.profile,
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const SplashScreen(),
  );
}
