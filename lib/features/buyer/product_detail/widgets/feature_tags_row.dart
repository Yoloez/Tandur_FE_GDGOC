import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

/// Horizontal row of feature tag chips (Organik, Bebas Pestisida, etc.).
class FeatureTagsRow extends StatelessWidget {
  final List<String> features;

  const FeatureTagsRow({super.key, required this.features});

  static const _icons = {
    'organik': Icons.eco_rounded,
    'bebas pestisida': Icons.shield_outlined,
    'panen hari ini': Icons.wb_sunny_outlined,
    'premium': Icons.workspace_premium_outlined,
    'alami': Icons.grass_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: features.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final feature = features[index];
          final icon =
              _icons[feature.toLowerCase()] ?? Icons.check_circle_outline;
          return _FeatureChip(label: feature, icon: icon);
        },
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FeatureChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
