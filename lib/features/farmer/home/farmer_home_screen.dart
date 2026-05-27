import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/features/auth/providers/auth_provider.dart';
import 'providers/farmer_home_provider.dart';
import 'models/farmer_home_data.dart';
import 'widgets/farmer_app_bar.dart';
import 'widgets/sales_summary_card.dart';
import 'widgets/order_stats_row.dart';
import 'widgets/product_stats_card.dart';
import 'widgets/main_menu_section.dart';
import 'widgets/insight_card.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  late final FarmerHomeProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = FarmerHomeProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_provider, AuthProvider.instance]),
          builder: (context, _) {
            final currentUser = AuthProvider.instance.currentUser;
            final name = currentUser?.namaLengkap.isNotEmpty == true
                ? currentUser!.namaLengkap
                : 'Petani';
            final avatarUrl = AuthProvider.instance.avatarUrl;

            return RefreshIndicator(
              onRefresh: () async {
                await AuthProvider.instance.fetchCurrentUser();
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App bar ──
                  FarmerAppBar(
                    greeting: _provider.greeting,
                    name: name,
                    avatarUrl: avatarUrl,
                  ),

                  const SizedBox(height: 16),

                  // ── Sales card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SalesSummaryCard(data: _provider.sales),
                  ),

                  const SizedBox(height: 14),

                  // ── Order stats ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OrderStatsRow(stats: _provider.orderStats),
                  ),

                  const SizedBox(height: 14),

                  // ── Product chart ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ProductStatsCard(bars: _provider.chartBars),
                  ),

                  const SizedBox(height: 24),

                  // ── Main menu ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MainMenuSection(
                      items: _provider.menuItems.map((item) {
                        if (item.label == 'Kelola\nProduk') {
                          return MenuItem(
                            icon: item.icon,
                            label: item.label,
                            onTap: () => context.pushNamed(
                              AppRoutes.farmerManageProducts,
                            ),
                          );
                        }
                        if (item.label == 'Upload\nProduk') {
                          return MenuItem(
                            icon: item.icon,
                            label: item.label,
                            onTap: () => context.pushNamed(
                              AppRoutes.farmerUploadProduct,
                            ),
                          );
                        }
                        return item;
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Insight card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InsightCard(data: _provider.insight),
                  ),
                ],
              ),
              ),
            );
          },
        ),
      ),
    );
  }
}
