import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/auth/models/auth_models.dart';
import 'package:tandur/features/auth/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';

  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  
  // User data decoded from token
  String? _userRole;
  String? _userEmail;
  String? _userId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;
  
  String? get userRole => _userRole;
  String? get userEmail => _userEmail;
  String? get userId => _userId;

  static final AuthProvider instance = AuthProvider._internal();

  factory AuthProvider() {
    return instance;
  }

  AuthProvider._internal() {
    _loadToken();
  }

  /// Initialize state from SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token != null) {
      _token = token;
      ApiClient.setToken(token);
      _decodeToken(token);
      notifyListeners();
    }
  }

  /// Decode JWT payload to get user data
  void _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded) as Map<String, dynamic>;

      _userEmail = data['email'] as String?;
      _userId = data['sub'] as String?;
      _userRole = data['role'] as String?;
    } catch (e) {
      debugPrint('Error decoding token: $e');
    }
  }

  /// Handle login process
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequest(email: email.trim(), pass: password);
    final response = await AuthService.login(request);

    _isLoading = false;

    if (response.success && response.token != null) {
      _token = response.token;
      ApiClient.setToken(response.token!);
      _decodeToken(response.token!);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.token!);
      
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Login gagal. Periksa kembali email dan password Anda.';
      notifyListeners();
      return false;
    }
  }

  /// Handle logout process
  Future<void> logout() async {
    _token = null;
    _userRole = null;
    _userEmail = null;
    _userId = null;
    ApiClient.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    
    notifyListeners();
  }
  
  /// Clear error state manually
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
