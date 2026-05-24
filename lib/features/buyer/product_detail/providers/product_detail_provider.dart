import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import '../models/product_detail_data.dart';

/// Provides product detail data fetching from backend.
class ProductDetailProvider extends ChangeNotifier {
  ProductDetail? _product;
  bool _isLoading = false;
  String? _errorMessage;

  ProductDetail? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch product detail by ID.
  Future<void> loadProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get('products/$productId');
      
      final data = response.data;
      if (data is Map) {
        _product = ProductDetail.fromJson(data.cast<String, dynamic>());
      } else {
        throw Exception('Gagal memproses data produk.');
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        _errorMessage = (e.response!.data as Map)['message'] ?? 'Gagal memuat detail produk.';
      } else {
        _errorMessage = 'Gagal memuat produk. Periksa koneksi internet Anda.';
      }
      _product = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _product = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
