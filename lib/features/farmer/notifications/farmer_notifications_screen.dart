import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

class FarmerNotificationsScreen extends StatelessWidget {
  const FarmerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Notifikasi',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada notifikasi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
