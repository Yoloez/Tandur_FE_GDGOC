import 'package:flutter/material.dart';
import 'package:tandur/features/buyer/home/models/buyer_home_data.dart';
import 'package:tandur/features/farmer/upload_product/models/product_category.dart';
import '../services/buyer_market_service.dart';

class BuyerMarketProvider extends ChangeNotifier {
  static final BuyerMarketProvider instance = BuyerMarketProvider._internal();
  BuyerMarketProvider._internal() {
    _init();
  }
  factory BuyerMarketProvider() => instance;

  // ── Products state ──
  List<ProductItem> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _searchQuery;

  // ── Pagination ──
  int _currentPage = 1;
  ProductMeta _meta = ProductMeta.empty;

  // ── Categories ──
  List<ProductCategory> _apiCategories = [];
  ProductCategory? _selectedCategory; // null = "Semua"
  bool _isLoadingCategories = false;
  bool _hasFetchedInitially = false;

  // ── Sort ──
  String? _sortOrder; // null = default, 'asc' = termurah, 'desc' = termahal

  // ── Getters ──
  List<ProductItem> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get searchQuery => _searchQuery;

  int get currentPage => _currentPage;
  ProductMeta get meta => _meta;
  int get totalPages => _meta.totalPages;

  List<ProductCategory> get apiCategories => _apiCategories;
  ProductCategory? get selectedCategory => _selectedCategory;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get sortOrder => _sortOrder;

  Future<void>? _initFuture;

  Future<void> _init() async {
    _initFuture = _loadCategories();
    await _initFuture;
  }
  
  Future<void> initialize({
    String? initialSearchQuery,
    String? initialCategoryName,
  }) async {
    if (_initFuture != null) {
      await _initFuture;
    }

    bool shouldRefetch = false;

    if (initialSearchQuery != null && initialSearchQuery != _searchQuery) {
      _searchQuery = initialSearchQuery;
      shouldRefetch = true;
    }

    if (initialCategoryName != null) {
      final category = _apiCategories
          .where((c) => c.nama.toLowerCase() == initialCategoryName.toLowerCase())
          .firstOrNull;
      
      if (category != null && _selectedCategory?.id != category.id) {
        _selectedCategory = category;
        shouldRefetch = true;
      }
    }
    
    if (shouldRefetch) {
      _hasFetchedInitially = false; // Force refetch if search query or category changed from external
    }
    
    if (_hasFetchedInitially) return;
    _hasFetchedInitially = true;
    
    await loadProducts();
  }

  Future<void> _loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _apiCategories = await BuyerMarketService.fetchCategories();
    } catch (_) {
      // Non-fatal: categories just won't be available
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    if (page != null) _currentPage = page;
    notifyListeners();

    try {
      final result = await BuyerMarketService.fetchProducts(
        kategoriId: _selectedCategory?.id,
        searchQuery: _searchQuery,
        page: _currentPage,
        sort: _sortOrder,
      );
      _products = result.products;
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(ProductCategory? category) {
    if (_selectedCategory?.id == category?.id) return;
    _selectedCategory = category;
    _currentPage = 1;
    loadProducts();
  }

  void setSearchQuery(String? query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    loadProducts();
  }

  void setSortOrder(String? sort) {
    if (_sortOrder == sort) return;
    _sortOrder = sort;
    _currentPage = 1;
    loadProducts();
  }

  void clearSearchQuery() {
    if (_searchQuery == null) return;
    _searchQuery = null;
    _currentPage = 1;
    loadProducts();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages || page == _currentPage) return;
    loadProducts(page: page);
  }
}
