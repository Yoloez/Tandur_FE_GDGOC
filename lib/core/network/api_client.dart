import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Singleton Dio client configured with base URL from .env.
///
/// Usage:
/// ```dart
/// final response = await ApiClient.dio.post('/auth/register', data: {...});
/// ```
class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL_API'] ?? '',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ),
    );

  /// Set auth token after login/register.
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear auth token on logout.
  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}
