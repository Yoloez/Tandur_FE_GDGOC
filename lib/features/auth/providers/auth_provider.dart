import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/features/auth/models/auth_models.dart';
import 'package:tandur/features/auth/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';

  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  bool _isInitializing = true;

  // User data decoded from token
  String? _userRole;
  String? _userEmail;
  String? _userId;

  // Full user profile data
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  bool get isInitializing => _isInitializing;

  String? get userRole => _userRole;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  UserModel? get currentUser => _currentUser;

  String? get avatarUrl {
    final photo = _currentUser?.fotoProfil;
    if (photo == null || photo.isEmpty) return null;
    if (photo.startsWith('http')) return photo;

    final baseUrl = dotenv.env['BASE_URL_API'] ?? '';
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$cleanBaseUrl/uploads/temp/$photo';
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

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
      await fetchCurrentUser();
    }

    _isInitializing = false;
    notifyListeners();
  }

  /// Fetch the full user profile from the server
  Future<void> fetchCurrentUser() async {
    if (!isAuthenticated) return;

    try {
      final response = await ApiClient.dio.get('users/me');
      _currentUser = UserModel.fromJson(response.data);
      notifyListeners();
    } on DioException catch (e) {
      debugPrint('Failed to fetch user profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        // Token might be invalid or expired
        await logout();
      }
    } catch (e) {
      debugPrint('Error parsing user profile: $e');
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

  /// Manually handle login with a provided token (e.g. from registration)
  Future<void> handleTokenLogin(String token) async {
    _token = token;
    ApiClient.setToken(token);
    _decodeToken(token);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    await fetchCurrentUser();
    notifyListeners();
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

      await fetchCurrentUser();

      notifyListeners();
      return true;
    } else {
      _errorMessage =
          response.message ??
          'Login gagal. Periksa kembali email dan password Anda.';
      notifyListeners();
      return false;
    }
  }

  /// Handle Google Login process
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_isGoogleSignInInitialized) {
        await _googleSignIn.initialize(
          clientId: dotenv.env['GOOGLE_CLIENT_ID'],
          serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
        );
        _isGoogleSignInInitialized = true;
      }

      // Sign out akun sebelumnya terlebih dahulu agar user bisa selalu memilih akun Gmail yang berbeda saat testing
      await _googleSignIn.signOut();

      // Picu pop-up Google Sign-In di perangkat perangkat
      late final GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        _isLoading = false;
        if (e.code == GoogleSignInExceptionCode.canceled) {
          // User menekan tombol kembali atau membatalkan pilihan login
          notifyListeners();
          return false;
        }
        _errorMessage = 'Gagal login Google: ${e.description ?? e.code.name}';
        notifyListeners();
        return false;
      }

      // Ambil otentikasi dari akun Google yang dipilih
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _isLoading = false;
        _errorMessage = 'Gagal mendapatkan ID Token dari Google.';
        notifyListeners();
        return false;
      }

      // Lempar idToken (JWT Google) ke Backend lewat AuthService yang sudah kamu buat
      final response = await AuthService.loginWithGoogle(idToken);

      _isLoading = false;

      // Jika Backend memvalidasi id_token sukses & mengembalikan JWT Token aplikasi Tandur
      if (response.success && response.token != null) {
        _token = response.token;
        ApiClient.setToken(response.token!);
        _decodeToken(response.token!);

        // Simpan token aplikasi ke SharedPreferences agar sesi tetap terjaga
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, response.token!);

        await fetchCurrentUser();

        notifyListeners();
        return true;
      } else {
        // Menangkap pesan error dari backend (Misal: "Email belum terdaftar, silakan sign up manual")
        _errorMessage = response.message ?? 'Gagal masuk menggunakan Google.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem: $e';
      notifyListeners();
      return false;
    }
  }

  /// Debug login bypassing backend
  Future<bool> debugLogin(String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    _token = 'debug_token_$role';
    _userRole = role;
    _userEmail = 'debug_$role@example.com';
    _userId = 'debug_id';

    ApiClient.setToken(_token!);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);

    notifyListeners();
    return true;
  }

  /// Update User Profile
  Future<bool> updateProfile(RegisterRequest request, {File? profilePhoto}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.updateProfile(request, profilePhoto: profilePhoto);

    _isLoading = false;

    if (response.success) {
      await fetchCurrentUser(); // Refresh the current user profile from backend
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Gagal memperbarui profil.';
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
    _currentUser = null;
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
