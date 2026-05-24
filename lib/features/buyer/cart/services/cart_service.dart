import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/buyer/cart/models/cart_model.dart';

/// Handles all cart-related API communication.
class CartService {
  const CartService._();

  /// POST /cart — Add product to cart.
  static Future<void> addToCart({
    required String productId,
    required int jumlah,
  }) async {
    try {
      await ApiClient.dio.post(
        'cart',
        data: {
          'productId': productId,
          'jumlah': jumlah,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// GET /cart — Fetch all cart items.
  static Future<List<CartItem>> fetchCart() async {
    try {
      final response = await ApiClient.dio.get('cart');
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => CartItem.fromJson(e.cast<String, dynamic>()))
            .toList();
      }

      if (data is Map) {
        // Support wrapped responses like { "data": [...] }
        final list = data['data'] ?? data['items'] ?? data['cart'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => CartItem.fromJson(e.cast<String, dynamic>()))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// PATCH /cart/{id} — Update quantity.
  static Future<void> updateQuantity({
    required String cartId,
    required int jumlah,
  }) async {
    try {
      await ApiClient.dio.patch(
        'cart/$cartId',
        data: {'jumlah': jumlah},
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// DELETE /cart/{id} — Remove item from cart.
  static Future<void> removeFromCart({required String cartId}) async {
    try {
      await ApiClient.dio.delete('cart/$cartId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  static String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      return data['message']?.toString() ?? 'Terjadi kesalahan pada server.';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi timeout. Periksa internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      default:
        return 'Terjadi kesalahan. Coba lagi nanti.';
    }
  }
}
