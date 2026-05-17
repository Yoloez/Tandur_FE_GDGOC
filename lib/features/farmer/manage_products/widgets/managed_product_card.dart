import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import '../models/managed_product_data.dart';

/// Product card with image, status badge, name, price, stock, and action buttons.
class ManagedProductCard extends StatelessWidget {
  final ManagedProduct product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdateStock;

  const ManagedProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product image + badge ──
          _ImageSection(product: product),

          // ── Info + actions ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + Price ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Origin: ${product.origin}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: product.priceFormatted,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: '/${product.unit}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Stock info ──
                Row(
                  children: [
                    Icon(
                      product.isOutOfStock
                          ? Icons.error_outline_rounded
                          : Icons.inventory_2_outlined,
                      size: 16,
                      color: product.isOutOfStock
                          ? const Color(0xFFE76F51)
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product.isOutOfStock
                          ? 'Stok: 0 ${product.stockUnit}'
                          : 'Tersedia: ${product.stock} ${product.stockUnit}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: product.isOutOfStock
                            ? const Color(0xFFE76F51)
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Action buttons ──
                Row(
                  children: [
                    if (product.isOutOfStock) ...[
                      _ActionChip(
                        icon: Icons.edit_outlined,
                        label: 'Update Stok',
                        onTap: onUpdateStock,
                        isPrimary: true,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.delete_outline_rounded,
                        label: 'Hapus',
                        onTap: onDelete,
                        isDestructive: true,
                      ),
                    ] else ...[
                      _ActionChip(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.delete_outline_rounded,
                        label: 'Hapus',
                        onTap: onDelete,
                        isDestructive: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product image with status badge and out-of-stock overlay ──
class _ImageSection extends StatelessWidget {
  final ManagedProduct product;

  const _ImageSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              product.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Icon(
                  Icons.eco_rounded,
                  size: 48,
                  color: AppColors.outline,
                ),
              ),
            ),

            // ── Out-of-stock overlay ──
            if (product.isOutOfStock)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Stok Kosong',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Status badge ──
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: product.isOutOfStock
                      ? AppColors.onSurfaceVariant
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.isOutOfStock ? 'Habis' : 'Aktif',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

// ── Reusable action chip button ──
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color textColor;
    final Color bgColor;

    if (isPrimary) {
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.06);
    } else if (isDestructive) {
      borderColor = const Color(0xFFE76F51);
      textColor = const Color(0xFFE76F51);
      bgColor = const Color(0xFFE76F51).withValues(alpha: 0.06);
    } else {
      borderColor = AppColors.outlineVariant;
      textColor = AppColors.onSurfaceVariant;
      bgColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
