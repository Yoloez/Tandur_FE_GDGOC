import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/auth/models/auth_models.dart';

/// Handles all authentication-related API calls.
class AuthService {
  const AuthService._();

  /// POST /auth/register
  static Future<AuthResponse> register(RegisterRequest request, {File? profilePhoto}) async {
    try {
      final dataMap = request.toJson();
      final formData = FormData.fromMap(dataMap);

      if (profilePhoto != null) {
        String fileName = profilePhoto.path.split('/').last;
        formData.files.add(
          MapEntry(
            'fotoProfil',
            await MultipartFile.fromFile(profilePhoto.path, filename: fileName),
          ),
        );
      }

      final response = await ApiClient.dio.post(
        'auth/register',
        data: formData,
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return AuthResponse(success: false, message: message);
    } catch (e) {
      return const AuthResponse(
        success: false,
        message: 'Terjadi kesalahan. Coba lagi nanti.',
      );
    }
  }

  /// PATCH /users/me
  static Future<AuthResponse> updateProfile(RegisterRequest request, {File? profilePhoto}) async {
    try {
      final dataMap = request.toJson();
      final formData = FormData.fromMap(dataMap);

      if (profilePhoto != null) {
        String fileName = profilePhoto.path.split('/').last;
        formData.files.add(
          MapEntry(
            'fotoProfil',
            await MultipartFile.fromFile(profilePhoto.path, filename: fileName),
          ),
        );
      }

      final response = await ApiClient.dio.patch(
        'users/me',
        data: formData,
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return AuthResponse(success: false, message: message);
    } catch (e) {
      return const AuthResponse(
        success: false,
        message: 'Terjadi kesalahan. Coba lagi nanti.',
      );
    }
  }

  /// POST /auth/login
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/login',
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return AuthResponse(success: false, message: message);
    } catch (e) {
      return const AuthResponse(
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

  static Future<AuthResponse> loginWithGoogle(String idToken) async {
    try {
      final response = await ApiClient.dio.post(
        'auth/google', // Sesuaikan nama path ini dengan buatan anak backend-mu
        data: {
          'idToken': idToken, // Payload yang diminta oleh backend
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return AuthResponse(success: false, message: message);
    } catch (e) {
      return const AuthResponse(
        success: false,
        message: 'Terjadi kesalahan. Coba lagi nanti.',
      );
    }
  }
}
