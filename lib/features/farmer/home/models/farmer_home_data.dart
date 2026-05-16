import 'package:flutter/material.dart';

/// Sales summary data for the farmer dashboard.
class SalesSummary {
  final String totalFormatted;
  final double growthPercent;
  final String growthLabel;

  const SalesSummary({
    required this.totalFormatted,
    required this.growthPercent,
    required this.growthLabel,
  });
}

/// Order statistics (new orders, ready to ship, etc.).
class OrderStat {
  final IconData icon;
  final int count;
  final String label;

  const OrderStat({
    required this.icon,
    required this.count,
    required this.label,
  });
}

/// A single bar in the product statistics chart.
class ChartBar {
  final String label;
  final double value; // 0.0 – 1.0 normalized

  const ChartBar({required this.label, required this.value});
}

/// Quick-access menu item.
class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// Insight / educational card data.
class InsightItem {
  final String badge;
  final String title;
  final String description;
  final String image;

  const InsightItem({
    required this.badge,
    required this.title,
    required this.description,
    required this.image,
  });
}
