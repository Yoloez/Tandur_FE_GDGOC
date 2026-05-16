import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';

/// Bottom navigation bar for the farmer shell.
///
/// Matches the design reference: vertical icon + label, green active indicator
/// line above selected item, clean surface background.
class FarmerBottomNav extends StatelessWidget {
  final int currentIndex;

  const FarmerBottomNav({super.key, required this.currentIndex});

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: 'Market'),
    _NavItem(icon: Icons.notifications_none_rounded, activeIcon: Icons.notifications_rounded, label: 'Notifications'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.goNamed(AppRoutes.farmerHome);
      case 1:
        context.goNamed(AppRoutes.farmerMarket);
      case 2:
        context.goNamed(AppRoutes.farmerNotifications);
      case 3:
        context.goNamed(AppRoutes.farmerProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(context, index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Active indicator line ──
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        height: 3,
                        width: isActive ? 24 : 0,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // ── Icon ──
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 24,
                        color: isActive ? AppColors.primary : AppColors.outline,
                      ),

                      const SizedBox(height: 4),

                      // ── Label ──
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive ? AppColors.primary : AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
