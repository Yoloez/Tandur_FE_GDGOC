import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/features/buyer/checkout/providers/checkout_provider.dart';

import 'widgets/checkout_address_section.dart';
import 'widgets/checkout_order_section.dart';
import 'widgets/checkout_payment_method_section.dart';
import 'widgets/checkout_summary_section.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CheckoutProvider.instance.fetchTransaction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.beVietnamPro(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: CheckoutProvider.instance,
        builder: (context, _) {
          final provider = CheckoutProvider.instance;

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: provider.fetchTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.transaction == null) {
            return const Center(child: Text('Tidak ada rincian pesanan'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              const CheckoutAddressSection(),
              const SizedBox(height: 24),
              CheckoutOrderSection(transaction: provider.transaction!),
              const SizedBox(height: 24),
              const CheckoutPaymentMethodSection(),
              const SizedBox(height: 24),
              CheckoutSummarySection(transaction: provider.transaction!),
            ],
          );
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: CheckoutProvider.instance,
        builder: (context, _) {
          final provider = CheckoutProvider.instance;
          if (provider.isLoading || provider.transaction == null) {
            return const SizedBox.shrink();
          }
          return _buildBottomNav(context, provider.transaction!.totalPembayaran);
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, String totalPembayaran) {
    // totalPembayaran might be a string like "0.00" or a large integer formatted. We'll format it assuming it's a double/int string.
    final total = double.tryParse(totalPembayaran)?.toInt() ?? 0;
    final totalFormatted = 'Rp ${total.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pembayaran',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalFormatted,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pesanan berhasil dibuat!')),
                );
                // Optionally pop or redirect to success page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Bayar Sekarang',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
