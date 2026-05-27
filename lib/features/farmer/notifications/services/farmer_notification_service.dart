import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/farmer/notifications/models/farmer_notification_model.dart';

class FarmerNotificationService {
  const FarmerNotificationService._();

  static Future<List<FarmerTransactionModel>> fetchNotifications() async {
    try {
      final response = await ApiClient.dio.get('transactions');
      
      final data = response.data;
      
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => FarmerTransactionModel.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      
      if (data is Map) {
        final list = data['data'] ?? data['transactions'] ?? [];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => FarmerTransactionModel.fromJson(e.cast<String, dynamic>()))
              .toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(data['message']?.toString() ?? 'Gagal memuat notifikasi');
      }
      throw Exception('Kesalahan jaringan. Gagal memuat notifikasi.');
    }
  }

  static Future<FarmerTransactionModel> fetchTransactionDetail(String id) async {
    try {
      final response = await ApiClient.dio.get('transactions/$id');
      final data = response.data;
      if (data is Map) {
        final item = data['data'] ?? data;
        return FarmerTransactionModel.fromJson(item.cast<String, dynamic>());
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

  static Future<FarmerTransactionModel?> updateTransactionStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await ApiClient.dio.patch(
        'transactions/$id/status',
        data: {'status': status},
      );
      final data = response.data;
      if (data is Map) {
        try {
          return FarmerTransactionModel.fromJson(
            data.cast<String, dynamic>(),
          );
        } catch (_) {
          return null; // response format unexpected, handle gracefully
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(
          data['message']?.toString() ?? 'Gagal mengubah status pesanan',
        );
      }
      throw Exception('Kesalahan jaringan. Gagal mengubah status pesanan.');
    }
  }
}
