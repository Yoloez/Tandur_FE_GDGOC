import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import '../models/farmer_home_data.dart';

class MainMenuSection extends StatelessWidget {
  final List<MenuItem> items;

  const MainMenuSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Utama',
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: items.map((item) => _MenuTile(item: item)).toList(),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final MenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
