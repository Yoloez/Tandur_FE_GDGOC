import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';

class CheckoutService {
  const CheckoutService._();

  /// POST /transactions/checkout — Create a new checkout transaction.
  static Future<Map<String, dynamic>> checkout({
    required String petaniId,
    required String tanggalPengambilan,
    required String metodePembayaran,
    required String status,
    required int totalHarga,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        'transactions/checkout',
        data: {
          'petaniId': petaniId,
          'tanggalPengambilan': tanggalPengambilan,
          'metodePembayaran': metodePembayaran,
          'status': status,
          'totalHarga': totalHarga,
          'items': items,
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data
          : <String, dynamic>{};
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(data['message']?.toString() ?? 'Gagal melakukan checkout');
      }
      throw Exception('Kesalahan jaringan');
    }
  }
}
