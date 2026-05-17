import 'package:flutter/material.dart';
import 'package:tandur/core/constants/color.dart';
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

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailProvider _provider;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _provider = ProductDetailProvider();
    _provider.addListener(_onProviderUpdate);
    _provider.loadProduct(widget.productId);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _provider.dispose();
    super.dispose();
  }

  void _onProviderUpdate() {
    if (mounted) setState(() {});
  }

  void _onAddToCart() {
    final product = _provider.product;
    if (product == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity × ${product.name} ditambahkan ke keranjang'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _provider.product;

    if (_provider.isLoading || product == null) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
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
                    weight: product.weight,
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
      bottomNavigationBar: ProductBottomBar(
        quantity: _quantity,
        onIncrement: () => setState(() => _quantity++),
        onDecrement: () {
          if (_quantity > 1) setState(() => _quantity--);
        },
        onAddToCart: _onAddToCart,
      ),
    );
  }
}
