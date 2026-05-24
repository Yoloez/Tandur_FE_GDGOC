import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/core/services/onboarding_prefs.dart';

import 'package:tandur/features/auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _startSequence();
  }

  Future<void> _startSequence() async {
    final isFirstLaunch = OnboardingPrefs.isFirstLaunch();
    final auth = AuthProvider.instance;

    // Brief pause then fade in
    await Future.delayed(const Duration(milliseconds: 200));
    _controller.forward();

    // Hold splash for a natural beat
    await Future.delayed(const Duration(milliseconds: 2200));

    // Wait until auth finishes its initial token check
    while (auth.isInitializing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final firstLaunch = await isFirstLaunch;
    if (mounted) {
      if (auth.isAuthenticated) {
        if (auth.userRole == 'petani') {
          context.goNamed(AppRoutes.farmerHome);
        } else {
          context.goNamed(AppRoutes.buyerHome);
        }
      } else if (firstLaunch) {
        context.goNamed(AppRoutes.onboarding);
      } else {
        context.goNamed(AppRoutes.welcome);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Logo ──
              Image.asset(
                'assets/images/tandur-logo-no-bg.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              // ── App name ──
              Text(
                'Tandur',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 6),

              // ── Tagline ──
              Text(
                'Digital Agronomy Ecosystem',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.outline,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
