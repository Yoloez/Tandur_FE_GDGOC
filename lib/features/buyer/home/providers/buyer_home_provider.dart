import 'package:flutter/material.dart';
import 'package:tandur/features/buyer/home/services/buyer_home_service.dart';
import 'package:tandur/features/buyer/market/services/buyer_market_service.dart';
import '../models/buyer_home_data.dart';

/// Provides data for the buyer home screen.
///
/// Static data (categories) is kept in-memory.
/// Farmers and Products are fetched from the backend.
class BuyerHomeProvider extends ChangeNotifier {
  String get location => 'Jakarta Selatan';

  // ── Categories ──
  List<CategoryItem> get categories => const [
    CategoryItem(icon: Icons.eco_rounded, label: 'Sayuran'),
    CategoryItem(icon: Icons.apple_rounded, label: 'Buah'),
    CategoryItem(icon: Icons.grain_rounded, label: 'Beras'),
    CategoryItem(icon: Icons.spa_rounded, label: 'Bumbu'),
  ];

  // ── Verified farmers (from API) ──
  List<FarmerItem> _farmers = [];
  bool _isLoadingFarmers = false;
  String? _farmersError;

  List<FarmerItem> get farmers => _farmers;
  bool get isLoadingFarmers => _isLoadingFarmers;
  String? get farmersError => _farmersError;

  // ── Fresh products (from API) ──
  List<ProductItem> _products = [];
  bool _isLoadingProducts = false;
  String? _productsError;

  List<ProductItem> get products => _products;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;

  /// Fetch the top 4 farmers
  Future<void> loadFarmers() async {
    _isLoadingFarmers = true;
    _farmersError = null;
    notifyListeners();

    try {
      _farmers = await BuyerHomeService.fetchFarmers(page: 1, limit: 4);
    } catch (e) {
      _farmersError = e.toString().replaceAll('Exception: ', '');
      _farmers = [];
    } finally {
      _isLoadingFarmers = false;
      notifyListeners();
    }
  }

  /// Fetch the latest products from the backend.
  /// Fetches without category filter to get all latest products.
  Future<void> loadProducts() async {
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();

    try {
      final result = await BuyerMarketService.fetchProducts();
      _products = result.products;
    } catch (e) {
      _productsError = e.toString().replaceAll('Exception: ', '');
      _products = [];
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }
}
