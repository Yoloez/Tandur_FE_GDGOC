import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/buyer/orders/models/buyer_order_model.dart';

class BuyerOrderService {
  const BuyerOrderService._();

  static Future<List<BuyerOrderModel>> fetchOrders() async {
    try {
      final response = await ApiClient.dio.get('transactions');
      
      final data = response.data;
      
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => BuyerOrderModel.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      
      if (data is Map) {
        final list = data['data'] ?? data['transactions'] ?? [];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => BuyerOrderModel.fromJson(e.cast<String, dynamic>()))
              .toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(data['message']?.toString() ?? 'Gagal memuat daftar pesanan');
      }
      throw Exception('Kesalahan jaringan. Gagal memuat daftar pesanan.');
    }
  }

  static Future<BuyerOrderModel> fetchOrderDetail(String id) async {
    try {
      final response = await ApiClient.dio.get('transactions/$id');
      final data = response.data;
      if (data is Map) {
        final item = data['data'] ?? data;
        return BuyerOrderModel.fromJson(item.cast<String, dynamic>());
      }
      throw Exception('Data detail pesanan tidak valid');
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(data['message']?.toString() ?? 'Gagal memuat detail pesanan');
      }
      throw Exception('Kesalahan jaringan. Gagal memuat detail pesanan.');
    }
  }
}
