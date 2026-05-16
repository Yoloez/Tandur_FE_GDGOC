import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import '../models/farmer_home_data.dart';

class ProductStatsCard extends StatelessWidget {
  final List<ChartBar> bars;

  const ProductStatsCard({super.key, required this.bars});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistik Produk',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.outline,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Bar chart ──
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((bar) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: bar.value,
                            child: Container(
                              width: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bar.label,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
