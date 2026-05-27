import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/widgets/skeleton_box.dart';
import 'package:tandur/features/auth/providers/auth_provider.dart';
import 'package:tandur/features/buyer/orders/widgets/full_screen_map_screen.dart';
import 'package:tandur/features/farmer/notifications/models/farmer_notification_model.dart';
import 'package:tandur/features/farmer/notifications/providers/farmer_notification_provider.dart';
import 'package:tandur/features/farmer/notifications/services/farmer_notification_service.dart';

class FarmerNotificationDetailScreen extends StatefulWidget {
  final String transactionId;

  const FarmerNotificationDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<FarmerNotificationDetailScreen> createState() =>
      _FarmerNotificationDetailScreenState();
}

class _FarmerNotificationDetailScreenState
    extends State<FarmerNotificationDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  FarmerTransactionModel? _transaction;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await FarmerNotificationService.fetchTransactionDetail(
        widget.transactionId,
      );
      final currentFarmerId = AuthProvider.instance.userId;

      // Filter items so we only display items belonging to this farmer
      final farmerItems = detail.items.where((item) {
        return item.product.petaniId == currentFarmerId;
      }).toList();

      setState(() {
        _transaction = FarmerTransactionModel(
          id: detail.id,
          pembeliId: detail.pembeliId,
          petaniId: detail.petaniId,
          totalPembayaran: detail.totalPembayaran,
          metodeBayar: detail.metodeBayar,
          statusPembayaran: detail.statusPembayaran,
          statusPesanan: detail.statusPesanan,
          status: detail.status,
          tanggalPengambilan: detail.tanggalPengambilan,
          buktiBayarUrl: detail.buktiBayarUrl,
          createdAt: detail.createdAt,
          items: farmerItems,
          pembeli: detail.pembeli,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      await FarmerNotificationProvider.instance.updateStatus(
        widget.transactionId,
        newStatus,
      );
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status pesanan berhasil diperbarui'),
            backgroundColor: AppColors.primary,
          ),
        );
        _fetchDetail(); // refresh detail view
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showStatusUpdateModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ubah Status Pesanan',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusOption('diterima', 'Diterima'),
              _buildStatusOption('ditolak', 'Ditolak'),
              _buildStatusOption('selesai', 'Selesai'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(String statusCode, String statusName) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        _updateStatus(statusCode);
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getStatusColor(statusCode).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.circle, size: 16, color: _getStatusColor(statusCode)),
      ),
      title: Text(
        statusName,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Detail Pesanan',
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: _buildBody(),
      bottomNavigationBar: _transaction != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _showStatusUpdateModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Ubah Status Pesanan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _FarmerNotificationDetailSkeleton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_transaction == null) {
      return const Center(child: Text('Data pesanan tidak ditemukan'));
    }

    int totalPrice = 0;
    for (var item in _transaction!.items) {
      int itemPrice =
          int.tryParse(item.hargaSnapshot) ?? item.product.harga ?? 0;
      totalPrice += itemPrice * item.jumlah;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status & Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(
              _transaction!.statusPesanan,
            ).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getStatusColor(
                _transaction!.statusPesanan,
              ).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status Pesanan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        _transaction!.statusPesanan,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(_transaction!.statusPesanan),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(_transaction!.statusPesanan),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                color: _getStatusColor(
                  _transaction!.statusPesanan,
                ).withValues(alpha: 0.2),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal Pemesanan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatDate(_transaction!.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              if (_transaction!.tanggalPengambilan != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Waktu Pengambilan',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatDate(_transaction!.tanggalPengambilan!),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Buyer Details
        Text(
          'Detail Pembeli',
          style: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _transaction!.pembeli?.namaLengkap ?? 'Pembeli',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _transaction!.pembeli?.nomorTelepon ?? '-',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _transaction!.pembeli?.alamatLengkap ??
                          'Alamat tidak tersedia',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (_transaction!.pembeli?.titikKoordinat != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      final lat =
                          double.tryParse(
                            _transaction!.pembeli!.titikKoordinat!.latitude,
                          ) ??
                          -6.200000;
                      final lng =
                          double.tryParse(
                            _transaction!.pembeli!.titikKoordinat!.longitude,
                          ) ??
                          106.816666;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenMapScreen(
                            location: LatLng(lat, lng),
                            title:
                                _transaction!.pembeli?.namaLengkap ??
                                'Lokasi Pembeli',
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: AbsorbPointer(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              double.tryParse(
                                    _transaction!
                                        .pembeli!
                                        .titikKoordinat!
                                        .latitude,
                                  ) ??
                                  -6.200000,
                              double.tryParse(
                                    _transaction!
                                        .pembeli!
                                        .titikKoordinat!
                                        .longitude,
                                  ) ??
                                  106.816666,
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('buyer_location'),
                              position: LatLng(
                                double.tryParse(
                                      _transaction!
                                          .pembeli!
                                          .titikKoordinat!
                                          .latitude,
                                    ) ??
                                    -6.200000,
                                double.tryParse(
                                      _transaction!
                                          .pembeli!
                                          .titikKoordinat!
                                          .longitude,
                                    ) ??
                                    106.816666,
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue,
                              ),
                            ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Product Items
        Text(
          'Daftar Produk',
          style: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ..._transaction!.items.map((item) {
          int itemPrice =
              int.tryParse(item.hargaSnapshot) ?? item.product.harga ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.surfaceContainerHighest,
                    child:
                        item.product.fotoUrl.isNotEmpty &&
                            item.product.fotoUrl.first.startsWith('http')
                        ? Image.network(
                            item.product.fotoUrl.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.image_not_supported_rounded,
                                  color: AppColors.outline,
                                ),
                          )
                        : const Icon(
                            Icons.eco_rounded,
                            color: AppColors.outline,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.namaProduk,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.jumlah} ${item.product.tipeStok} x ${_formatCurrency(itemPrice)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(item.jumlah * itemPrice),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // Payment Info
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pendapatan',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                _formatCurrency(totalPrice),
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'diterima':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return AppColors.outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

class _FarmerNotificationDetailSkeleton extends StatelessWidget {
  const _FarmerNotificationDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Status card skeleton
          SkeletonBox(width: double.infinity, height: 120, radius: 16),
          SizedBox(height: 24),
          // Location card skeleton
          SkeletonBox(width: double.infinity, height: 200, radius: 16),
          SizedBox(height: 24),
          // Items skeleton
          SkeletonBox(width: double.infinity, height: 100, radius: 16),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 100, radius: 16),
          SizedBox(height: 24),
          // Summary skeleton
          SkeletonBox(width: double.infinity, height: 150, radius: 16),
        ],
      ),
    );
  }
}
