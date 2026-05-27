import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import '../models/harga_pangan_models.dart';

/// API service for harga pangan (food price) endpoints.
class HargaPanganService {
  const HargaPanganService._();

  /// GET /hargapangan/markets
  static Future<List<Market>> fetchMarkets() async {
    try {
      final response = await ApiClient.dio.get('hargapangan/markets');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => Market.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (_) {
      throw Exception('Gagal memuat data pasar.');
    }
  }

  /// GET /hargapangan/prices
  static Future<PriceResponse> fetchPrices({
    required int pasarId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'hargapangan/prices',
        queryParameters: {
          'pasarId': pasarId,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PriceResponse.fromJson(data);
      }
      throw Exception('Format respons tidak valid.');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat harga pangan.');
    }
  }

  static String _extractError(DioException e) {
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
