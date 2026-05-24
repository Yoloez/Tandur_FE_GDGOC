import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/features/buyer/cart/providers/cart_provider.dart';
import 'providers/product_detail_provider.dart';
import 'widgets/product_hero_image.dart';
import 'widgets/product_info_section.dart';
import 'widgets/farmer_info_card.dart';
import 'widgets/feature_tags_row.dart';
import 'widgets/product_description_section.dart';
import 'widgets/reviews_section.dart';
import 'widgets/product_bottom_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ProductDetailProvider _provider;
  int _quantity = 1;
  bool _isAddingToCart = false;

  // Animation for success overlay
  late final AnimationController _successController;
  late final Animation<double> _successScale;
  late final Animation<double> _successOpacity;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _provider = ProductDetailProvider();
    _provider.addListener(_onProviderUpdate);
    _provider.loadProduct(widget.productId);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _provider.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onProviderUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _onAddToCart() async {
    final product = _provider.product;
    if (product == null || _isAddingToCart) return;

    setState(() => _isAddingToCart = true);

    try {
      await CartProvider.instance.addToCart(
        productId: widget.productId,
        jumlah: _quantity,
      );

      if (!mounted) return;

      // Show success animation
      setState(() => _showSuccess = true);
      _successController.forward(from: 0.0);

      // Auto-hide after 1.8s
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) {
        _successController.reverse();
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) setState(() => _showSuccess = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.inter(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _provider.product;

    if (_provider.isLoading) {
      return _ProductDetailSkeleton(
        onBack: () => Navigator.of(context).pop(),
      );
    }

    if (_provider.errorMessage != null || product == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _provider.errorMessage ?? 'Produk tidak ditemukan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _provider.loadProduct(widget.productId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ──
                ProductHeroImage(image: product.image),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Product info ──
                      ProductInfoSection(
                        name: product.name,
                        priceFormatted: product.priceFormatted,
                        tipeStok: product.tipeStok,
                        stok: product.stok,
                        badge: product.badge,
                      ),

                      const SizedBox(height: 16),

                      // ── Farmer card ──
                      FarmerInfoCard(
                        farmName: product.farmName,
                        farmLocation: product.farmLocation,
                        rating: product.farmRating,
                      ),

                      const SizedBox(height: 18),

                      // ── Feature tags ──
                      FeatureTagsRow(features: product.features),

                      const SizedBox(height: 20),

                      // ── Description + health ──
                      ProductDescriptionSection(
                        description: product.description,
                        healthBenefits: product.healthBenefits,
                      ),

                      const SizedBox(height: 24),

                      // ── Reviews ──
                      ReviewsSection(reviews: product.reviews),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Success overlay ──
          if (_showSuccess)
            AnimatedBuilder(
              animation: _successController,
              builder: (context, child) {
                return Opacity(
                  opacity: _successOpacity.value,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: ScaleTransition(
                        scale: _successScale,
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 32),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Berhasil!',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$_quantity item ditambahkan\nke keranjang',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: ProductBottomBar(
        quantity: _quantity,
        isLoading: _isAddingToCart,
        onIncrement: () => setState(() => _quantity++),
        onDecrement: () {
          if (_quantity > 1) setState(() => _quantity--);
        },
        onAddToCart: _onAddToCart,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Skeleton loading screen
// ──────────────────────────────────────────────────────────────
class _ProductDetailSkeleton extends StatefulWidget {
  final VoidCallback onBack;
  const _ProductDetailSkeleton({required this.onBack});

  @override
  State<_ProductDetailSkeleton> createState() => _ProductDetailSkeletonState();
}

class _ProductDetailSkeletonState extends State<_ProductDetailSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final lo = AppColors.surfaceContainerLow;
          final hi = AppColors.surfaceContainerHighest;
          final shimmer = Color.lerp(lo, hi, _anim.value)!;

          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image skeleton ──
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(child: Container(color: shimmer)),
                      // Back button placeholder
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: GestureDetector(
                          onTap: widget.onBack,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest
                                  .withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Product name ──
                      _Bone(width: double.infinity, height: 24, shimmer: shimmer),
                      const SizedBox(height: 8),
                      _Bone(width: 200, height: 24, shimmer: shimmer),

                      const SizedBox(height: 14),

                      // ── Price row ──
                      Row(
                        children: [
                          _Bone(width: 110, height: 20, shimmer: shimmer),
                          const SizedBox(width: 10),
                          _Bone(width: 50, height: 16, shimmer: shimmer),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Farmer card skeleton ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.outlineVariant
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: shimmer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Bone(width: 120, height: 14, shimmer: shimmer),
                                const SizedBox(height: 6),
                                _Bone(width: 80, height: 12, shimmer: shimmer),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Feature tags skeleton ──
                      Row(
                        children: [
                          _Bone(width: 80, height: 32, shimmer: shimmer, radius: 20),
                          const SizedBox(width: 8),
                          _Bone(width: 90, height: 32, shimmer: shimmer, radius: 20),
                          const SizedBox(width: 8),
                          _Bone(width: 70, height: 32, shimmer: shimmer, radius: 20),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Description skeleton ──
                      _Bone(width: 130, height: 18, shimmer: shimmer),
                      const SizedBox(height: 12),
                      _Bone(width: double.infinity, height: 13, shimmer: shimmer),
                      const SizedBox(height: 6),
                      _Bone(width: double.infinity, height: 13, shimmer: shimmer),
                      const SizedBox(height: 6),
                      _Bone(width: 200, height: 13, shimmer: shimmer),

                      const SizedBox(height: 24),

                      // ── Reviews skeleton ──
                      _Bone(width: 100, height: 18, shimmer: shimmer),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.outlineVariant
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: shimmer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Bone(
                                      width: 100,
                                      height: 13,
                                      shimmer: shimmer),
                                  const SizedBox(height: 6),
                                  _Bone(
                                      width: double.infinity,
                                      height: 12,
                                      shimmer: shimmer),
                                  const SizedBox(height: 4),
                                  _Bone(
                                      width: 160, height: 12, shimmer: shimmer),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // ── Bottom bar skeleton ──
      bottomNavigationBar: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final shimmer = Color.lerp(
            AppColors.surfaceContainerLow,
            AppColors.surfaceContainerHighest,
            _anim.value,
          )!;
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  _Bone(width: 100, height: 44, shimmer: shimmer, radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Bone(
                        width: double.infinity,
                        height: 44,
                        shimmer: shimmer,
                        radius: 14),
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

/// A single rounded rectangle skeleton bone.
class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final Color shimmer;
  final double radius;

  const _Bone({
    required this.width,
    required this.height,
    required this.shimmer,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shimmer,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
