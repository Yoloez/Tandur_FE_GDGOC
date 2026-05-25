import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import '../models/buyer_home_data.dart';

class BuyerHomeService {
  const BuyerHomeService._();

  static Future<List<FarmerItem>> fetchFarmers({int page = 1, int limit = 4}) async {
    try {
      final response = await ApiClient.dio.get(
        '/users/petani',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => FarmerItem.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(data['message']?.toString() ?? 'Gagal memuat daftar petani.');
      }
      throw Exception('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw Exception('Gagal memuat daftar petani.');
    }
  }
}
