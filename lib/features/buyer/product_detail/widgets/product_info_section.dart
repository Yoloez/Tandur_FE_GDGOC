import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

/// Product name, badge, price, stock and unit row.
class ProductInfoSection extends StatelessWidget {
  final String name;
  final String priceFormatted;
  final String tipeStok; // e.g. "kg", "ikat"
  final int stok;
  final String? badge;

  const ProductInfoSection({
    super.key,
    required this.name,
    required this.priceFormatted,
    required this.tipeStok,
    required this.stok,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor(badge!).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _badgeColor(badge!).withValues(alpha: 0.3)),
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

        // ── Price + unit ──
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
            if (tipeStok.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                '/ $tipeStok',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),

        // ── Stock indicator ──
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: stok > 0 ? AppColors.primary : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              stok > 0 ? 'Stok: $stok $tipeStok' : 'Stok habis',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: stok > 0
                    ? AppColors.onSurfaceVariant
                    : AppColors.error,
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
      case 'tersedia':
        return AppColors.primary;
      default:
        return AppColors.outline;
    }
  }
}
