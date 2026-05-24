import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/features/buyer/checkout/models/transaction_model.dart';

class CheckoutSummarySection extends StatelessWidget {
  final TransactionModel transaction;
  
  const CheckoutSummarySection({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Determine total formatting
    final totalPembayaran = double.tryParse(transaction.totalPembayaran)?.toInt() ?? 0;
    
    // In a real app, subtotal would be computed from items.
    int subtotal = 0;
    for (var item in transaction.items) {
      if (item.product.harga != null) {
        subtotal += item.product.harga! * item.jumlah;
      }
    }
    
    // Fallback if totalPembayaran isn't just the sum (e.g. shipping, service fees)
    // Here we just display the given totalPembayaran.
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RINGKASAN PEMBAYARAN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal Produk', _formatCurrency(subtotal)),
          const SizedBox(height: 12),
          _buildSummaryRow('Total Ongkos Kirim', 'Rp -'), // Placeholder since it's not in the response yet
          const SizedBox(height: 12),
          _buildSummaryRow('Biaya Layanan', 'Rp -'), // Placeholder
          const SizedBox(height: 16),
          Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Tagihan',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                _formatCurrency(totalPembayaran),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}
