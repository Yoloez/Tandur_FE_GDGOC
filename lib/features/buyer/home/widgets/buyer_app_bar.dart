import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

/// Top bar: location pin + text | brand name | search icon
class BuyerAppBar extends StatelessWidget {
  final String location;

  const BuyerAppBar({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // ── Brand ──
          Text(
            'Tandur',
            style: GoogleFonts.beVietnamPro(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),

          const Spacer(),

          // ── Search ──
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLowest,
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLowest,
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
