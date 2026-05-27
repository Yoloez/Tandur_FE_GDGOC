import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import '../models/harga_pangan_models.dart';

/// API service for harga pangan (food price) endpoints.
class HargaPanganService {
  const HargaPanganService._();

  /// GET /hargapangan/provinces
  static Future<List<Province>> fetchProvinces() async {
    try {
      final response = await ApiClient.dio.get('hargapangan/provinces');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => Province.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (_) {
      throw Exception('Gagal memuat data provinsi.');
    }
  }

  /// GET /hargapangan/market-types
  static Future<List<MarketType>> fetchMarketTypes() async {
    try {
      final response = await ApiClient.dio.get('hargapangan/market-types');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => MarketType.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (_) {
      throw Exception('Gagal memuat tipe pasar.');
    }
  }

  /// GET /hargapangan/prices
  static Future<PriceResponse> fetchPrices({
    required int provinceId,
    required int marketTypeId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'hargapangan/prices',
        queryParameters: {
          'provinceId': provinceId,
          'marketTypeId': marketTypeId,
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
