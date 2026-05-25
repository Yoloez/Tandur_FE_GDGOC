import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/features/buyer/widgets/app_shell.dart';
import 'package:tandur/features/buyer/home/buyer_home_page.dart';
import 'package:tandur/features/auth/providers/auth_provider.dart';
import 'package:tandur/features/auth/login/login_screen.dart';
import 'package:tandur/features/farmer/home/farmer_home_screen.dart';
import 'package:tandur/features/farmer/market/farmer_market_screen.dart';
import 'package:tandur/features/farmer/notifications/farmer_notifications_screen.dart';
import 'package:tandur/features/farmer/profile/farmer_profile_screen.dart';
import 'package:tandur/features/farmer/widgets/farmer_shell.dart';
import 'package:tandur/features/onboarding/screens/onboarding_screen.dart';
import 'package:tandur/features/buyer/profile/profile_screen.dart';
import 'package:tandur/features/auth/register/register_screen.dart';
import 'package:tandur/features/buyer/product_detail/product_detail_screen.dart';
import 'package:tandur/features/farmer/manage_products/manage_products_screen.dart';
import 'package:tandur/features/farmer/upload_product/upload_product_screen.dart';
import 'package:tandur/features/splash/splash_screen.dart';
import 'package:tandur/features/welcome/welcome_screen.dart';
import 'package:tandur/features/buyer/cart/cart_screen.dart';
import 'package:tandur/features/buyer/checkout/checkout_screen.dart';
import 'package:tandur/features/buyer/market/buyer_market_screen.dart';
import 'package:tandur/features/buyer/farmers/farmer_list_screen.dart';

class AppRoutes {
  static const String splash = 'splash';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String register = 'register';
  static const String onboarding = 'onboarding';

  // ── Farmer routes ──
  static const String farmerHome = 'farmer-home';
  static const String farmerMarket = 'farmer-market';
  static const String farmerNotifications = 'farmer-notifications';
  static const String farmerProfile = 'farmer-profile';
  static const String farmerManageProducts = 'farmer-manage-products';
  static const String farmerUploadProduct = 'farmer-upload-product';

  // ── Buyer routes ──
  static const String buyerHome = 'buyer-home';
  static const String buyerMarket = 'buyer-market';
  static const String buyerProfile = 'buyer-profile';
  static const String productDetail = 'product-detail';
  static const String buyerCart = 'buyer-cart';
  static const String buyerCheckout = 'buyer-checkout';
  static const String farmerList = 'farmer-list';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: AuthProvider.instance,
    redirect: (context, state) {
      final auth = AuthProvider.instance;

      // Let Splash Screen always show initially so the animation can play.
      // The Splash screen handles the initial routing after its animation.
      if (state.uri.path == '/') return null;

      if (auth.isInitializing) return null;

      final isAuthRoute = state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          state.uri.path == '/welcome' ||
          state.uri.path == '/onboarding';

      if (auth.isAuthenticated) {
        // If logged in, prevent accessing auth routes
        if (isAuthRoute) {
          return auth.userRole == 'petani' ? '/farmer/home' : '/buyer/home';
        }
      } else {
        // If not logged in, prevent accessing protected routes
        if (!isAuthRoute) {
          return '/welcome';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboarding,
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),
      GoRoute(
        name: AppRoutes.welcome,
        path: '/welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),
      GoRoute(
        name: AppRoutes.register,
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      // ── Product detail (no bottom nav) ──
      GoRoute(
        name: AppRoutes.productDetail,
        path: '/product/:id',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: productId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
            transitionDuration: const Duration(milliseconds: 350),
          );
        },
      ),
      GoRoute(
        path: '/products/:id',
        redirect: (context, state) => '/product/${state.pathParameters['id']}',
      ),

      // ── Buyer Cart (no bottom nav) ──
      GoRoute(
        name: AppRoutes.buyerCart,
        path: '/buyer-cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        name: AppRoutes.buyerCheckout,
        path: '/buyer-checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      // ── Farmer List (no bottom nav) ──
      GoRoute(
        name: AppRoutes.farmerList,
        path: '/farmer-list',
        builder: (context, state) => const FarmerListScreen(),
      ),

      // ── Farmer manage products (no bottom nav) ──
      GoRoute(
        name: AppRoutes.farmerManageProducts,
        path: '/farmer/manage-products',
        builder: (context, state) => const ManageProductsScreen(),
      ),

      // ── Farmer upload product (no bottom nav) ──
      GoRoute(
        name: AppRoutes.farmerUploadProduct,
        path: '/farmer/upload-product',
        builder: (context, state) => const UploadProductScreen(),
      ),

      // ── Farmer shell with bottom navbar ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FarmerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.farmerHome,
                path: '/farmer/home',
                builder: (context, state) => const FarmerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.farmerMarket,
                path: '/farmer/market',
                builder: (context, state) => const FarmerMarketScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.farmerNotifications,
                path: '/farmer/notifications',
                builder: (context, state) => const FarmerNotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.farmerProfile,
                path: '/farmer/profile',
                builder: (context, state) => const FarmerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Buyer shell (existing) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.buyerHome,
                path: '/buyer/home',
                builder: (context, state) => const BuyerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.buyerMarket,
                path: '/buyer/market',
                builder: (context, state) {
                  final query = state.uri.queryParameters['q'];
                  return BuyerMarketScreen(initialSearchQuery: query);
                },
              ),
            ],
          ),
          // Empty branch for 'Pantau' to match bottom nav index 2
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/pantau',
                builder: (context, state) => const Scaffold(body: Center(child: Text('Fitur belum tersedia.'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.buyerProfile,
                path: '/buyer/profile',
                builder: (context, state) => const BuyerProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const SplashScreen(),
  );
}
