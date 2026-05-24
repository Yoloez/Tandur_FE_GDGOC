import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/features/buyer/checkout/models/transaction_model.dart';

class CheckoutOrderSection extends StatelessWidget {
  final TransactionModel transaction;
  
  const CheckoutOrderSection({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.shopping_basket_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Rincian Pesanan',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...transaction.items.map((item) {
          final imageUrl = item.product.fotoUrl.isNotEmpty 
              ? item.product.fotoUrl.first 
              : '';
              
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFarmCard(
              farmName: 'Mitra Tani', // Replace with actual farmer name if available
              productName: item.product.namaProduk,
              price: item.product.priceFormatted,
              quantity: item.jumlah,
              shippingMethod: 'Reguler', // Placeholder
              shippingEstimation: 'Estimasi tiba 12-14 Okt', // Placeholder
              shippingCost: 'Rp 10.000', // Placeholder
              imagePath: imageUrl,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFarmCard({
    required String farmName,
    required String productName,
    required String price,
    required int quantity,
    required String shippingMethod,
    required String shippingEstimation,
    required String shippingCost,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Farm Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  farmName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          
          // Product Detail
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                    color: AppColors.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(imagePath),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jumlah: $quantity',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Shipping Method
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'METODE PENGIRIMAN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shippingMethod,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shippingEstimation,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        shippingCost,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.eco_rounded,
          color: AppColors.outline,
        ),
      );
    }
    if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.eco_rounded,
          color: AppColors.outline,
        ),
      );
    }
    return const Icon(Icons.eco_rounded, color: AppColors.outline);
  }
}
