import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

/// Sticky bottom bar with quantity selector and "Tambah Keranjang" button.
class ProductBottomBar extends StatelessWidget {
  final int quantity;
  final bool isLoading;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToCart;

  const ProductBottomBar({
    super.key,
    required this.quantity,
    this.isLoading = false,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ── Quantity selector ──
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove_rounded,
                    onTap: onDecrement,
                    enabled: quantity > 1 && !isLoading,
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$quantity',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add_rounded,
                    onTap: onIncrement,
                    enabled: !isLoading,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ── Add to cart button ──
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.6),
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Tambah ke Keranjang',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
    );
  }
}
