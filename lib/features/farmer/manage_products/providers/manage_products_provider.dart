import 'package:flutter/material.dart';
import '../models/managed_product_data.dart';
import '../services/manage_products_service.dart';

/// Status filter tabs aligned to API values.
enum ProductStatusFilter { semua, active, nonActive, pending }

extension ProductStatusFilterExt on ProductStatusFilter {
  String get label {
    switch (this) {
      case ProductStatusFilter.semua:
        return 'Semua';
      case ProductStatusFilter.active:
        return 'Aktif';
      case ProductStatusFilter.nonActive:
        return 'Nonaktif';
      case ProductStatusFilter.pending:
        return 'Pending';
    }
  }

  /// API value — null means no status filter (fetch all).
  String? get apiValue {
    switch (this) {
      case ProductStatusFilter.semua:
        return null;
      case ProductStatusFilter.active:
        return 'active';
      case ProductStatusFilter.nonActive:
        return 'non-active';
      case ProductStatusFilter.pending:
        return 'pending';
    }
  }
}

class ManageProductsProvider extends ChangeNotifier {
  // ── state ──
  List<ManagedProduct> _products = [];
  ProductMeta _meta = const ProductMeta(total: 0, page: 1, limit: 10, totalPages: 1);
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;
  ProductStatusFilter _statusFilter = ProductStatusFilter.semua;
  int _currentPage = 1;
  final int _limit = 10;

  // ── getters ──
  List<ManagedProduct> get products => _products;
  ProductMeta get meta => _meta;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  ProductStatusFilter get statusFilter => _statusFilter;
  int get currentPage => _currentPage;
  bool get hasNextPage => _currentPage < _meta.totalPages;
  bool get hasPrevPage => _currentPage > 1;

  ProductStats get stats {
    final total = _meta.total;
    final active = _products.where((p) => p.status == ProductStatus.active).length;
    final outOfStock = _products.where((p) => p.isOutOfStock).length;
    final lowStock = _products.where((p) => p.stok > 0 && p.stok <= 5).length;
    return ProductStats(
      totalProducts: total,
      active: active,
      outOfStock: outOfStock,
      lowStock: lowStock,
    );
  }

  // ── tab labels ──
  List<String> get tabLabels =>
      ProductStatusFilter.values.map((f) => f.label).toList();

  int get activeTabIndex => ProductStatusFilter.values.indexOf(_statusFilter);

  // ── public actions ──

  /// Called when user switches status tab.
  void setStatusFilter(ProductStatusFilter filter) {
    if (filter == _statusFilter) return;
    _statusFilter = filter;
    _currentPage = 1;
    notifyListeners();
    loadProducts();
  }

  /// Navigate pagination.
  void goToPage(int page) {
    if (page < 1 || page > _meta.totalPages) return;
    _currentPage = page;
    notifyListeners();
    loadProducts();
  }

  /// Initial / refresh load.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ManageProductsService.fetchMyProducts(
        page: _currentPage,
        limit: _limit,
        status: _statusFilter.apiValue,
      );
      _products = result.products;
      _meta = result.meta;
    } catch (e) {
      _products = [];
      _meta = const ProductMeta(total: 0, page: 1, limit: 10, totalPages: 1);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('ManageProductsProvider error: $_errorMessage');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Delete product via API, then remove locally on success.
  Future<void> deleteProduct(String id) async {
    _isDeleting = true;
    notifyListeners();

    try {
      await ManageProductsService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      // Also decrement total in meta
      _meta = ProductMeta(
        total: (_meta.total - 1).clamp(0, double.maxFinite.toInt()),
        page: _meta.page,
        limit: _meta.limit,
        totalPages: _meta.totalPages,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Delete failed: $_errorMessage');
    }

    _isDeleting = false;
    notifyListeners();
  }

  /// Toggle active ↔ non-active via API (optimistic update).
  Future<void> toggleActive(String id, bool makeActive) async {
    final statusString = makeActive ? 'active' : 'non-active';

    // Optimistic update
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final old = _products[index];
      _products[index] = ManagedProduct(
        id: old.id,
        name: old.name,
        petaniId: old.petaniId,
        deskripsi: old.deskripsi,
        priceFormatted: old.priceFormatted,
        harga: old.harga,
        tipeStok: old.tipeStok,
        stok: old.stok,
        fotoUrl: old.fotoUrl,
        status: old.stok <= 0
            ? ProductStatus.outOfStock
            : (makeActive ? ProductStatus.active : ProductStatus.nonActive),
        kategoriId: old.kategoriId,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }

    try {
      await ManageProductsService.updateProductStatus(id, statusString);
    } catch (e) {
      // Revert on failure
      await loadProducts();
    }
  }
}
