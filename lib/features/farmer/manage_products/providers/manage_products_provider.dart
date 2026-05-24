import 'package:flutter/material.dart';
import '../models/managed_product_data.dart';
import '../services/manage_products_service.dart';

/// Provides managed product data for the farmer.
///
/// Currently returns mock data. Replace methods with API calls:
/// ```dart
/// Future<void> loadProducts() async {
///   _isLoading = true;
///   notifyListeners();
///
///   final response = await dio.get('/api/farmer/products');
///   _products = (response.data['products'] as List)
///       .map((e) => ManagedProduct.fromJson(e))
///       .toList();
///   _stats = ProductStats.fromJson(response.data['stats']);
///
///   _isLoading = false;
///   notifyListeners();
/// }
///
/// Future<void> deleteProduct(String id) async {
///   await dio.delete('/api/farmer/products/$id');
///   _products.removeWhere((p) => p.id == id);
///   notifyListeners();
/// }
///
/// Future<void> updateStock(String id, int newStock) async {
///   await dio.patch('/api/farmer/products/$id', data: {'stock': newStock});
///   // refresh
///   await loadProducts();
/// }
/// ```
class ManageProductsProvider extends ChangeNotifier {
  List<ManagedProduct> _products = [];
  ProductStats _stats = const ProductStats(
    totalProducts: 0,
    lowStock: 0,
    active: 0,
    outOfStock: 0,
  );
  bool _isLoading = false;
  String _activeCategory = 'sayur';
  String? _errorMessage;

  List<ManagedProduct> get products => _products;
  ProductStats get stats => _stats;
  bool get isLoading => _isLoading;
  String get activeCategory => _activeCategory;
  String? get errorMessage => _errorMessage;

  List<String> get categories => const ['Sayur', 'Benih', 'Buah', 'Lainnya'];

  void setCategory(String category) {
    final next = category.toLowerCase();
    if (next == _activeCategory) return;
    _activeCategory = next;
    notifyListeners();
    loadProducts();
  }

  /// Load products — replace with API call.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await ManageProductsService.fetchProducts(
        kategori: _activeCategory,
      );

      _products = products;
      _stats = _calculateStats(products);
    } catch (e) {
      _products = [];
      _stats = const ProductStats(
        totalProducts: 0,
        lowStock: 0,
        active: 0,
        outOfStock: 0,
      );
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Failed to load products: $_errorMessage');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Delete a product — replace with API call.
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Update stock — replace with API call.
  Future<void> updateStock(String id, int newStock) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final old = _products[index];
      _products[index] = ManagedProduct(
        id: old.id,
        name: old.name,
        origin: old.origin,
        priceFormatted: old.priceFormatted,
        unit: old.unit,
        stock: newStock,
        stockUnit: old.stockUnit,
        image: old.image,
        status: newStock <= 0 
            ? ProductStatus.outOfStock 
            : (old.status == ProductStatus.outOfStock ? ProductStatus.active : old.status),
        category: old.category,
      );
      notifyListeners();
    }
  }

  /// Toggle active status via API call
  Future<void> toggleActive(String id, bool makeActive) async {
    final statusString = makeActive ? 'active' : 'pending';
    
    // Optimistic update
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final old = _products[index];
      _products[index] = ManagedProduct(
        id: old.id,
        name: old.name,
        origin: old.origin,
        priceFormatted: old.priceFormatted,
        unit: old.unit,
        stock: old.stock,
        stockUnit: old.stockUnit,
        image: old.image,
        status: old.stock <= 0 
            ? ProductStatus.outOfStock 
            : (makeActive ? ProductStatus.active : ProductStatus.pending),
        category: old.category,
      );
      _stats = _calculateStats(_products);
      notifyListeners();
    }

    try {
      await ManageProductsService.updateProductStatus(id, statusString);
    } catch (e) {
      // Revert on failure
      loadProducts();
    }
  }

  ProductStats _calculateStats(List<ManagedProduct> products) {
    final total = products.length;
    final outOfStock = products.where((p) => p.status == ProductStatus.outOfStock).length;
    final active = products.where((p) => p.status == ProductStatus.active).length;
    final lowStock = products.where((p) => p.stock > 0 && p.stock <= 5).length;

    return ProductStats(
      totalProducts: total,
      lowStock: lowStock,
      active: active,
      outOfStock: outOfStock,
    );
  }
}
