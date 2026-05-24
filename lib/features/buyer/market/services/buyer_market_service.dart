import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/buyer/home/models/buyer_home_data.dart';
import 'package:tandur/features/farmer/upload_product/models/product_category.dart';

/// Pagination metadata from the API.
class ProductMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProductMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 8,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  static const empty = ProductMeta(total: 0, page: 1, limit: 8, totalPages: 1);
}

class BuyerMarketService {
  const BuyerMarketService._();

  static const int _pageLimit = 8;

  /// GET /categories — shared with farmer upload feature.
  static Future<List<ProductCategory>> fetchCategories() async {
    try {
      final response = await ApiClient.dio.get('categories');
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => ProductCategory.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// GET /products with pagination and optional kategoriId filter.
  static Future<({List<ProductItem> products, ProductMeta meta})>
  fetchProducts({String? kategoriId, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': _pageLimit};
      if (kategoriId != null && kategoriId.isNotEmpty) {
        queryParams['kategoriId'] = kategoriId;
      }

      final response = await ApiClient.dio.get(
        'products',
        queryParameters: queryParams,
      );

      final rawData = response.data;

      // Parse paginated response: { data: [...], meta: {...} }
      List<Map<String, dynamic>> rawList = [];
      ProductMeta meta = ProductMeta.empty;

      if (rawData is Map) {
        if (rawData['data'] is List) {
          rawList = (rawData['data'] as List)
              .whereType<Map>()
              .cast<Map<String, dynamic>>()
              .toList();
        }
        if (rawData['meta'] is Map) {
          meta = ProductMeta.fromJson(
            (rawData['meta'] as Map).cast<String, dynamic>(),
          );
        }
      } else if (rawData is List) {
        rawList = rawData
            .whereType<Map>()
            .cast<Map<String, dynamic>>()
            .toList();
      }

      final products = rawList.map((json) => _parseProduct(json)).toList();
      return (products: products, meta: meta);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Gagal memuat produk. Coba lagi.');
    }
  }

  static ProductItem _parseProduct(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final namaProduk = json['namaProduk']?.toString() ?? 'Produk Tani';

    // fotoUrl is now a List<dynamic>
    String image = '';
    final fotoUrl = json['fotoUrl'];
    if (fotoUrl is List && fotoUrl.isNotEmpty) {
      image = fotoUrl.first?.toString() ?? '';
    } else if (fotoUrl is String) {
      image = fotoUrl;
    }

    // Price: use harga if available
    final hargaRaw = json['harga'];
    String priceFormatted;
    if (hargaRaw != null) {
      final hargaNum = double.tryParse(hargaRaw.toString());
      if (hargaNum != null) {
        final hargaInt = hargaNum.toInt();
        priceFormatted = 'Rp ${_formatNumber(hargaInt)}';
      } else {
        priceFormatted = 'Rp -';
      }
    } else {
      priceFormatted = 'Rp -';
    }

    final tipeStok = json['tipeStok']?.toString() ?? '';
    final status = json['status']?.toString() ?? '';

    String? badge;
    if (status == 'active') badge = 'Tersedia';

    return ProductItem(
      id: id,
      farmName: 'Mitra Tani',
      productName: namaProduk,
      priceFormatted: priceFormatted,
      badge: badge,
      image: image,
      tipeStok: tipeStok,
    );
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
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
