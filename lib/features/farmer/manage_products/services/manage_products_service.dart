import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/farmer/manage_products/models/managed_product_data.dart';

class ManageProductsService {
  const ManageProductsService._();

  /// Fetch farmer's own products from GET /products/me
  /// [status] can be 'active', 'non-active', or 'pending'.
  static Future<({List<ManagedProduct> products, ProductMeta meta})> fetchMyProducts({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await ApiClient.dio.get(
        '/products/me',
        queryParameters: queryParams,
      );

      final data = response.data;
      List<ManagedProduct> products = [];
      ProductMeta meta = const ProductMeta(total: 0, page: 1, limit: 10, totalPages: 1);

      if (data is Map) {
        // Parse meta
        if (data['meta'] is Map) {
          meta = ProductMeta.fromJson(Map<String, dynamic>.from(data['meta']));
        }
        // Parse data list
        if (data['data'] is List) {
          products = (data['data'] as List)
              .whereType<Map>()
              .map((e) => ManagedProduct.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return (products: products, meta: meta);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Gagal memuat produk. Coba lagi.');
    }
  }

  /// Delete a product by ID using DELETE /products/{id}
  static Future<void> deleteProduct(String id) async {
    try {
      await ApiClient.dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Gagal menghapus produk.');
    }
  }

  /// Update product status using PATCH /products/{id}/status
  static Future<void> updateProductStatus(String id, String status) async {
    try {
      await ApiClient.dio.patch(
        '/products/$id/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Gagal mengubah status produk.');
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
