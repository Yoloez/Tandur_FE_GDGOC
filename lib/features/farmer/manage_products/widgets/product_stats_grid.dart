import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import '../models/managed_product_data.dart';

/// 2×2 stats grid: Total Produk, Stok Rendah, Aktif, Habis.
class ProductStatsGrid extends StatelessWidget {
  final ProductStats stats;

  const ProductStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _StatCell(
          label: 'Total Produk',
          value: '${stats.totalProducts}',
          valueColor: AppColors.onSurface,
        ),
        _StatCell(
          label: 'Stok Rendah',
          value: '${stats.lowStock}',
          valueColor: const Color(0xFFE76F51),
        ),
        _StatCell(
          label: 'Aktif',
          value: '${stats.active}',
          valueColor: AppColors.primary,
        ),
        _StatCell(
          label: 'Habis',
          value: '${stats.outOfStock}',
          valueColor: const Color(0xFFE76F51),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCell({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
