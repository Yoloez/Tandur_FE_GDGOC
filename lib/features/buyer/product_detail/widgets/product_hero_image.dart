import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tandur/core/constants/color.dart';

/// Full-width product hero image using SliverAppBar with a glassmorphism
/// toolbar bar that stays pinned while the image scrolls away.
class ProductHeroImage extends StatelessWidget {
  final String image;
  final String productId;

  const ProductHeroImage({
    super.key,
    required this.image,
    required this.productId,
  });

  void _onShare(BuildContext context) {
    // Standard HTTPS link that opens the Tandur app directly via App Links
    final webLink = 'https://gdg.zemcode.my.id/products/$productId';
    SharePlus.instance.share(
      ShareParams(
        text: '🌱 Lihat produk segar ini di Tandur!\n$webLink',
        subject: 'Produk dari Tandur',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 60,
      // ── Full-width glassmorphism toolbar ──
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // How collapsed the app bar is (0 = fully expanded, 1 = fully collapsed)
          final expandedHeight = 320 + statusBarHeight;
          final collapsedHeight = 60 + statusBarHeight;
          final t =
              ((expandedHeight - constraints.maxHeight) /
                      (expandedHeight - collapsedHeight))
                  .clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Product image ──
              Positioned.fill(child: _buildImage()),

              // ── Gradient for readability ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 140,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Glassmorphism action bar ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: statusBarHeight + 60,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: t > 0.85
                            ? AppColors.surface.withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.12),
                        border: Border(
                          bottom: BorderSide(
                            color: t > 0.85
                                ? AppColors.outlineVariant.withValues(
                                    alpha: 0.3,
                                  )
                                : Colors.white.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: statusBarHeight,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          // ── Back button ──
                          _ActionIcon(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).pop(),
                            collapsed: t > 0.85,
                          ),
                          const Spacer(),
                          // ── Share button ──
                          _ActionIcon(
                            icon: Icons.share_outlined,
                            onTap: () => _onShare(context),
                            collapsed: t > 0.85,
                          ),
                          const SizedBox(width: 6),
                          // ── Wishlist button ──
                          _WishlistButton(collapsed: t > 0.85),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    final isNetwork = image.startsWith('http');

    if (isNetwork) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      );
    }

    if (image.isEmpty) return _buildPlaceholder();

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Icon(Icons.eco_rounded, size: 64, color: AppColors.outline),
    );
  }
}

// ── Simple icon button that adapts colour based on collapse state ──
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool collapsed;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: collapsed
              ? AppColors.surfaceContainerLow
              : Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 21,
          color: collapsed ? AppColors.onSurface : Colors.white,
        ),
      ),
    );
  }
}

// ── Stateful Wishlist / Favorite button with bounce animation ──
class _WishlistButton extends StatefulWidget {
  final bool collapsed;
  const _WishlistButton({required this.collapsed});

  @override
  State<_WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<_WishlistButton>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _liked = !_liked);
    _ctrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _liked
                ? Colors.red.withValues(alpha: 0.85)
                : widget.collapsed
                ? AppColors.surfaceContainerLow
                : Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            size: 21,
            color: _liked
                ? Colors.white
                : widget.collapsed
                ? AppColors.onSurface
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
