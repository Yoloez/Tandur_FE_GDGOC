import 'package:flutter/material.dart';
import '../models/managed_product_data.dart';

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

  List<ManagedProduct> get products =>
      _products.where((p) => p.category == _activeCategory).toList();
  ProductStats get stats => _stats;
  bool get isLoading => _isLoading;
  String get activeCategory => _activeCategory;

  List<String> get categories => const ['Sayur', 'Benih'];

  void setCategory(String category) {
    _activeCategory = category.toLowerCase();
    notifyListeners();
  }

  /// Load products — replace with API call.
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _products = _mockProducts;
    _stats = const ProductStats(
      totalProducts: 24,
      lowStock: 3,
      active: 21,
      outOfStock: 3,
    );

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
        status: newStock > 0 ? ProductStatus.active : ProductStatus.outOfStock,
        category: old.category,
      );
      notifyListeners();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Mock data — remove when API is ready
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static final List<ManagedProduct> _mockProducts = [
    const ManagedProduct(
      id: 'wortel-organik',
      name: 'Wortel Organik',
      origin: 'Highland Farm',
      priceFormatted: 'Rp 12.500',
      unit: 'kg',
      stock: 45,
      stockUnit: 'kg',
      image: 'assets/images/onboarding_farm.jpg',
      status: ProductStatus.active,
      category: 'sayur',
    ),
    const ManagedProduct(
      id: 'bayam-hijau',
      name: 'Bayam Hijau',
      origin: 'Highland Farm',
      priceFormatted: 'Rp 8.000',
      unit: 'ikat',
      stock: 112,
      stockUnit: 'ikat',
      image: 'assets/images/onboarding_market.jpg',
      status: ProductStatus.active,
      category: 'sayur',
    ),
    const ManagedProduct(
      id: 'kentang-dieng',
      name: 'Kentang Dieng',
      origin: 'Highland Farm',
      priceFormatted: 'Rp 15.000',
      unit: 'kg',
      stock: 0,
      stockUnit: 'kg',
      image: 'assets/images/onboarding_tech.jpg',
      status: ProductStatus.outOfStock,
      category: 'sayur',
    ),
    const ManagedProduct(
      id: 'benih-tomat',
      name: 'Benih Tomat',
      origin: 'Highland Farm',
      priceFormatted: 'Rp 25.000',
      unit: 'pack',
      stock: 30,
      stockUnit: 'pack',
      image: 'assets/images/onboarding_farm.jpg',
      status: ProductStatus.active,
      category: 'benih',
    ),
  ];
}
