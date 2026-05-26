import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/farmer/upload_product/models/product_category.dart';
import 'package:tandur/features/farmer/upload_product/models/product_create_request.dart';

/// Handles product upload API calls.
class UploadProductService {
  const UploadProductService._();

  /// GET /categories — fetch all product categories.
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
    } catch (_) {
      throw Exception('Gagal memuat kategori.');
    }
  }

  /// POST /products/generate-description — generate AI product description.
  static Future<String> generateDescription({
    required File photo,
    required String namaProduk,
    required String kategoriId,
  }) async {
    try {
      final fileName = photo.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'namaProduk': namaProduk,
        'kategoriId': kategoriId,
        'file': await MultipartFile.fromFile(photo.path, filename: fileName),
      });

      final response = await ApiClient.dio.post(
        'products/generate-description',
        data: formData,
      );

      final data = response.data;
      if (data is Map && data['deskripsi'] != null) {
        return data['deskripsi'].toString();
      }
      throw Exception('Respons AI tidak valid.');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal generate deskripsi AI.');
    }
  }

  /// POST /products — create product with photos as multipart/form-data.
  static Future<void> createProduct(
    ProductCreateRequest request, {
    required List<File> photos,
  }) async {
    try {
      final fields = request.toFormFields();
      final formData = FormData.fromMap(fields);

      // Attach each photo under the 'files' key
      for (final photo in photos) {
        final fileName = photo.path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(photo.path, filename: fileName),
          ),
        );
      }

      await ApiClient.dio.post(
        'products',
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (_) {
      throw Exception('Gagal menyimpan produk. Coba lagi.');
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
