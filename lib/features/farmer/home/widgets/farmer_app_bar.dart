import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

class FarmerAppBar extends StatelessWidget {
  final String greeting;
  final String name;
  final String? avatarUrl;

  const FarmerAppBar({
    super.key,
    required this.greeting,
    required this.name,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // ── Avatar ──
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainer,
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? Image.network(avatarUrl!, fit: BoxFit.cover)
                  : const Icon(
                      Icons.person_rounded,
                      color: AppColors.outline,
                      size: 24,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Greeting text ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Halo, $name!',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // ── Notification bell ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLowest,
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
