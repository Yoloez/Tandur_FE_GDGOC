import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/farmer/manage_products/models/managed_product_data.dart';

class ManageProductsService {
  const ManageProductsService._();

  static Future<List<ManagedProduct>> fetchProducts({
    required String kategori,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'products',
        queryParameters: {'kategori': kategori},
      );

      final rawList = _extractList(response.data);
      return rawList.map((e) => ManagedProduct.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Gagal memuat produk. Coba lagi.');
    }
  }

  static Future<void> updateProductStatus(String id, String status) async {
    try {
      await ApiClient.dio.patch(
        'products/$id/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Gagal mengubah status produk.');
    }
  }

  static List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().cast<Map<String, dynamic>>().toList();
    }

    if (data is Map) {
      if (data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .cast<Map<String, dynamic>>()
            .toList();
      }
      if (data['products'] is List) {
        return (data['products'] as List)
            .whereType<Map>()
            .cast<Map<String, dynamic>>()
            .toList();
      }
      if (data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .cast<Map<String, dynamic>>()
            .toList();
      }
      if (data['id'] != null) {
        return [data.cast<String, dynamic>()];
      }
    }

    return [];
  }

  static String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      return data['message'] ?? 'Terjadi kesalahan pada server.';
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
