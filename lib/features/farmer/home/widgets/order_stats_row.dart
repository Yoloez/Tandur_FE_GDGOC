import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import '../models/farmer_home_data.dart';

class OrderStatsRow extends StatelessWidget {
  final List<OrderStat> stats;

  const OrderStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: stat == stats.last ? 0 : 12,
            ),
            child: _StatCard(stat: stat),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final OrderStat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            '${stat.count}',
            style: GoogleFonts.beVietnamPro(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
