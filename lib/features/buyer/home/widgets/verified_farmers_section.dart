import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import '../models/buyer_home_data.dart';

/// Verified farmers horizontal scroll section.
class VerifiedFarmersSection extends StatelessWidget {
  final List<FarmerItem> farmers;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const VerifiedFarmersSection({
    super.key, 
    required this.farmers,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Petani Terverifikasi',
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(AppRoutes.farmerList),
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── State handling ──
        if (isLoading)
          SizedBox(
            height: 160,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (errorMessage != null)
          SizedBox(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage!,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            ),
          )
        else if (farmers.isEmpty)
          SizedBox(
            height: 160,
            child: Center(
              child: Text(
                'Belum ada petani.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          // ── Cards ──
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: farmers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _FarmerCard(farmer: farmers[index]);
              },
            ),
          ),
      ],
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final FarmerItem farmer;

  const _FarmerCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Avatar ──
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer,
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: farmer.avatarUrl != null && farmer.avatarUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          farmer.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: AppColors.outline,
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: AppColors.outline,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceContainerLowest,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            farmer.name,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            farmer.location,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF4A261)),
              const SizedBox(width: 3),
              Text(
                farmer.rating.toString(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

