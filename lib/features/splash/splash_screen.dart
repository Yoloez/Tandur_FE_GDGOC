import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _exitController;

  // Background gradient animation
  late Animation<double> _bgAnimation;

  // Logo animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotate;

  // Text animations
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  // Particle / leaf animation
  late Animation<double> _particleAnim;

  // Exit animation
  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;

  final List<_Leaf> _leaves = [];

  @override
  void initState() {
    super.initState();

    // Generate random leaf positions
    final rng = math.Random(42);
    for (int i = 0; i < 12; i++) {
      _leaves.add(
        _Leaf(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          size: 14 + rng.nextDouble() * 22,
          angle: rng.nextDouble() * math.pi * 2,
          speed: 0.3 + rng.nextDouble() * 0.7,
          delay: rng.nextDouble() * 0.5,
          opacity: 0.05 + rng.nextDouble() * 0.12,
        ),
      );
    }

    // 1. Background expand
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeOut,
    );

    // 2. Logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _logoRotate = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // 3. Text entrance
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ),
        );

    // 4. Particle/leaf float
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _particleAnim = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );

    // 5. Exit animation
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _bgController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Hold for a moment then exit
    await Future.delayed(const Duration(milliseconds: 1800));
    await _exitController.forward();

    if (mounted) {
      context.goNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgAnimation,
          _logoController,
          _textController,
          _particleAnim,
          _exitController,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitOpacity,
            child: ScaleTransition(
              scale: _exitScale,
              child: Stack(
                children: [
                  // ── Background gradient ──
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0D2B1E),
                          Color(0xFF1B4332),
                          Color(0xFF2D6A4F),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // ── Radial glow behind logo ──
                  Center(
                    child: Opacity(
                      opacity: _logoOpacity.value * 0.4,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryLight.withOpacity(0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Floating leaves ──
                  ..._leaves.map((leaf) {
                    final t = (_particleAnim.value + leaf.delay) % 1.0;
                    final dy = -t * leaf.speed;
                    final wobble = math.sin(t * math.pi * 2) * 0.03;
                    return Positioned(
                      left: (leaf.x + wobble) * size.width,
                      top: (leaf.y + dy + 1.0) % 1.0 * size.height,
                      child: Transform.rotate(
                        angle: leaf.angle + t * math.pi,
                        child: Opacity(
                          opacity: leaf.opacity,
                          child: Text(
                            '🌿',
                            style: TextStyle(fontSize: leaf.size),
                          ),
                        ),
                      ),
                    );
                  }),

                  // ── Decorative rings ──
                  Center(
                    child: Opacity(
                      opacity: _logoOpacity.value * 0.15,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: _logoOpacity.value * 0.08,
                      child: Container(
                        width: 380,
                        height: 380,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Main content ──
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Logo
                      Transform.rotate(
                        angle: _logoRotate.value,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoOpacity,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: AppColors.primaryLight.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // App name
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: const Text(
                            'TANDUR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 10,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Divider line
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 1,
                              color: AppColors.primaryLight.withOpacity(0.5),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '🌱',
                              style: TextStyle(
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primaryLight.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 40,
                              height: 1,
                              color: AppColors.primaryLight.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      SlideTransition(
                        position: _taglineSlide,
                        child: FadeTransition(
                          opacity: _taglineOpacity,
                          child: Text(
                            'Tanam. Rawat. Panen.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Bottom loading dots
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: _LoadingDots(),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Leaf data model ──
class _Leaf {
  final double x, y, size, angle, speed, delay, opacity;
  const _Leaf({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
    required this.speed,
    required this.delay,
    required this.opacity,
  });
}

// ── Animated loading dots ──
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _anims = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0.3,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withOpacity(_anims[i].value),
            ),
          ),
        );
      }),
    );
  }
}
