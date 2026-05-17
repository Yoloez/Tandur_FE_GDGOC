import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'providers/buyer_home_provider.dart';
import 'widgets/buyer_app_bar.dart';
import 'widgets/hero_banner.dart';
import 'widgets/category_section.dart';
import 'widgets/verified_farmers_section.dart';
import 'widgets/fresh_products_section.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  late final BuyerHomeProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = BuyerHomeProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar (fixed/pinned) ──
            SliverAppBar(
              pinned: true,
              floating: false,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 60,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.none,
                background: BuyerAppBar(location: _provider.location),
              ),
            ),

            // ── Content ──
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 10),

                  // ── Hero banner ──
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: HeroBanner(),
                  ),

                  const SizedBox(height: 24),

                  // ── Categories ──
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: CategorySection(categories: _provider.categories),
                  ),

                  const SizedBox(height: 24),

                  // ── Verified farmers ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: VerifiedFarmersSection(farmers: _provider.farmers),
                  ),

                  const SizedBox(height: 24),

                  // ── Fresh products ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FreshProductsSection(
                      products: _provider.products,
                      onProductTap: (productId) {
                        context.pushNamed(
                          AppRoutes.productDetail,
                          pathParameters: {'id': productId},
                        );
                      },
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
