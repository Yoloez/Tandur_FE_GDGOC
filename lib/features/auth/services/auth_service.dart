import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/auth/models/auth_models.dart';

/// Handles all authentication-related API calls.
class AuthService {
  const AuthService._();

  /// POST /auth/register
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/register',
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return AuthResponse(success: false, message: message);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan. Coba lagi nanti.',
      );
    }
  }

  /// Extract a user-friendly error message from a DioException.
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
