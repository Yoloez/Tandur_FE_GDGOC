import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

/// Product name, badge, and price + weight row.
class ProductInfoSection extends StatelessWidget {
  final String name;
  final String priceFormatted;
  final String weight;
  final String? badge;

  const ProductInfoSection({
    super.key,
    required this.name,
    required this.priceFormatted,
    required this.weight,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Name + badge ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.3,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 10),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor(badge!).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _badgeColor(badge!).withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _badgeColor(badge!),
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // ── Price ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              priceFormatted,
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '/ $weight',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _badgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'organic':
        return AppColors.primary;
      case 'premium':
        return const Color(0xFFE76F51);
      case 'hydroponic':
        return AppColors.info;
      default:
        return AppColors.outline;
    }
  }
}
