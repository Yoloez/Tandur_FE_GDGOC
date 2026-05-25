import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import '../models/managed_product_data.dart';

/// 2×2 stats grid: Total Produk, Stok Rendah, Aktif, Habis.
class ProductStatsGrid extends StatelessWidget {
  final ProductStats stats;
  final bool isLoading;

  const ProductStatsGrid({super.key, required this.stats, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _StatCell(
          label: 'Total Produk',
          value: '${stats.totalProducts}',
          valueColor: AppColors.onSurface,
          isLoading: isLoading,
        ),
        _StatCell(
          label: 'Stok Rendah',
          value: '${stats.lowStock}',
          valueColor: const Color(0xFFE76F51),
          isLoading: isLoading,
        ),
        _StatCell(
          label: 'Aktif',
          value: '${stats.active}',
          valueColor: AppColors.primary,
          isLoading: isLoading,
        ),
        _StatCell(
          label: 'Habis',
          value: '${stats.outOfStock}',
          valueColor: const Color(0xFFE76F51),
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _StatCell extends StatefulWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isLoading;

  const _StatCell({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isLoading = false,
  });

  @override
  State<_StatCell> createState() => _StatCellState();
}

class _StatCellState extends State<_StatCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
    if (widget.isLoading) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StatCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          if (widget.isLoading)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: Container(
                    height: 24,
                    width: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            )
          else
            Text(
              widget.value,
              style: GoogleFonts.beVietnamPro(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: widget.valueColor,
              ),
            ),
        ],
      ),
    );
  }
}
