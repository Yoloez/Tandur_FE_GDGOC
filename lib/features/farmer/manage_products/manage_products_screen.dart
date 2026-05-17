import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'providers/manage_products_provider.dart';
import 'widgets/product_stats_grid.dart';
import 'widgets/managed_product_card.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen>
    with SingleTickerProviderStateMixin {
  late final ManageProductsProvider _provider;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _provider = ManageProductsProvider();
    _provider.addListener(_onProviderUpdate);
    _provider.loadProducts();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _provider.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onProviderUpdate() {
    if (mounted) setState(() {});
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _provider.setCategory(
        _provider.categories[_tabController.index],
      );
    }
  }

  void _onAddProduct() {
    context.pushNamed(AppRoutes.farmerUploadProduct);
  }

  void _onEditProduct(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit produk: $id'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onDeleteProduct(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Produk?',
          style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Produk yang dihapus tidak dapat dikembalikan.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _provider.deleteProduct(id);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.inter(
                color: const Color(0xFFE76F51),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onUpdateStock(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Update stok: $id'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Kelola Produk',
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.onSurface,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.outlineVariant.withValues(alpha: 0.3),
          tabs: _provider.categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: _provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  // ── Stats grid ──
                  ProductStatsGrid(stats: _provider.stats),

                  const SizedBox(height: 20),

                  // ── Product list ──
                  ..._provider.products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ManagedProductCard(
                        product: product,
                        onEdit: () => _onEditProduct(product.id),
                        onDelete: () => _onDeleteProduct(product.id),
                        onUpdateStock: () => _onUpdateStock(product.id),
                      ),
                    ),
                  ),

                  if (_provider.products.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 56,
                            color: AppColors.outline.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada produk',
                            style: GoogleFonts.inter(
                              fontSize: 15,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddProduct,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
