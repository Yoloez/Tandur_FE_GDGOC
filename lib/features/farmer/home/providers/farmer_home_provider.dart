import 'package:flutter/material.dart';
import '../models/farmer_home_data.dart';

/// Provides mock data and business logic for the farmer home dashboard.
///
/// In production, this would fetch from an API or local database.
/// Extend with ChangeNotifier / Riverpod / Bloc as needed.
class FarmerHomeProvider extends ChangeNotifier {
  // ── Greeting ──
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String get farmerName => 'Pak Budi';
  String? get avatarUrl => null; // placeholder for profile image

  // ── Sales summary ──
  SalesSummary get sales => const SalesSummary(
        totalFormatted: 'Rp 12.450.000',
        growthPercent: 12,
        growthLabel: '+12% Bulan ini',
      );

  // ── Order stats ──
  List<OrderStat> get orderStats => const [
        OrderStat(
          icon: Icons.receipt_long_rounded,
          count: 24,
          label: 'Pesanan Baru',
        ),
        OrderStat(
          icon: Icons.local_shipping_outlined,
          count: 8,
          label: 'Siap Kirim',
        ),
      ];

  // ── Product chart ──
  List<ChartBar> get chartBars => const [
        ChartBar(label: 'Sen', value: 0.65),
        ChartBar(label: 'Sel', value: 0.45),
        ChartBar(label: 'Rab', value: 0.80),
        ChartBar(label: 'Kam', value: 0.55),
        ChartBar(label: 'Jum', value: 0.70),
      ];

  // ── Main menu ──
  List<MenuItem> get menuItems => const [
        MenuItem(icon: Icons.inventory_2_outlined, label: 'Kelola\nProduk'),
        MenuItem(icon: Icons.add_box_outlined, label: 'Upload\nProduk'),
        MenuItem(icon: Icons.bar_chart_rounded, label: 'Analisis\nHarga'),
        MenuItem(icon: Icons.inbox_rounded, label: 'Pesanan\nMasuk'),
      ];

  // ── Insights ──
  InsightItem get insight => const InsightItem(
        badge: 'Wawasan Baru',
        title: 'Edukasi Tani Digital: Precision Farming',
        description: 'Meningkatkan hasil panen dengan data akurat.',
        image: 'assets/images/insight_farming.png',
      );
}
