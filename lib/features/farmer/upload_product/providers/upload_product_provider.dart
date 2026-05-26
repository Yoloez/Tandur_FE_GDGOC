import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tandur/features/farmer/upload_product/models/product_category.dart';
import 'package:tandur/features/farmer/upload_product/models/product_create_request.dart';
import 'package:tandur/features/farmer/upload_product/services/upload_product_service.dart';

class UploadProductProvider extends ChangeNotifier {
  static final UploadProductProvider instance =
      UploadProductProvider._internal();

  factory UploadProductProvider() {
    return instance;
  }

  UploadProductProvider._internal() {
    loadCategories();
  }

  // ── State ──
  bool _isSubmitting = false;
  bool _isLoadingCategories = false;
  bool _isGeneratingAi = false;
  String? _errorMessage;
  List<ProductCategory> _categories = [];
  ProductCategory? _selectedCategory;

  bool get isSubmitting => _isSubmitting;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isGeneratingAi => _isGeneratingAi;
  String? get errorMessage => _errorMessage;
  List<ProductCategory> get categories => _categories;
  ProductCategory? get selectedCategory => _selectedCategory;

  /// Load categories from GET /categories.
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await UploadProductService.fetchCategories();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    } catch (_) {
      // Non-fatal: fall back to empty list; screen handles gracefully
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// POST /products/generate-description — generate AI description.
  /// Returns the generated description string, or null on failure.
  Future<String?> generateAiDescription({
    required File photo,
    required String namaProduk,
  }) async {
    if (_selectedCategory == null) {
      _errorMessage = 'Pilih kategori produk terlebih dahulu.';
      notifyListeners();
      return null;
    }

    _isGeneratingAi = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final desc = await UploadProductService.generateDescription(
        photo: photo,
        namaProduk: namaProduk,
        kategoriId: _selectedCategory!.id,
      );
      return desc;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isGeneratingAi = false;
      notifyListeners();
    }
  }

  /// Submit product via POST /products multipart/form-data.
  Future<bool> submitProduct({
    required String namaProduk,
    required String deskripsi,
    required int stok,
    required String tipeStok,
    required List<File> photos,
    int? harga,
  }) async {
    if (_selectedCategory == null) {
      _errorMessage = 'Pilih kategori produk terlebih dahulu.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = ProductCreateRequest(
        namaProduk: namaProduk,
        kategoriId: _selectedCategory!.id,
        deskripsi: deskripsi,
        stok: stok,
        tipeStok: tipeStok,
        harga: harga,
      );

      await UploadProductService.createProduct(request, photos: photos);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
