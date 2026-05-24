import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tandur/features/auth/models/auth_models.dart';
import 'package:tandur/features/auth/services/auth_service.dart';

/// Manages registration state across role selection and form steps.
class RegisterProvider extends ChangeNotifier {
  // ── Step state ──
  String? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;
  bool _registrationSuccess = false;
  File? _profilePhoto;
  LatLng? _selectedLocation;

  String? get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get registrationSuccess => _registrationSuccess;
  bool get hasRole => _selectedRole != null;
  File? get profilePhoto => _profilePhoto;
  LatLng? get selectedLocation => _selectedLocation;

  String get roleLabel {
    switch (_selectedRole) {
      case 'petani':
        return 'Petani';
      case 'pembeli':
        return 'Pembeli';
      default:
        return '';
    }
  }

  void selectRole(String role) {
    _selectedRole = role;
    _errorMessage = null;
    notifyListeners();
  }

  void setProfilePhoto(File? photo) {
    _profilePhoto = photo;
    notifyListeners();
  }

  void setLocation(LatLng? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearRole() {
    _selectedRole = null;
    _errorMessage = null;
    _profilePhoto = null;
    _selectedLocation = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Validate required fields before submitting.
  String? validate({
    required String name,
    required String email,
    required String password,
  }) {
    if (name.trim().isEmpty) return 'Nama lengkap wajib diisi.';
    if (email.trim().isEmpty) return 'Email wajib diisi.';
    if (!email.contains('@')) return 'Format email tidak valid.';
    if (password.length < 8) return 'Password minimal 8 karakter.';
    return null; // valid
  }

  /// Submit registration to backend.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    // Client-side validation
    final validationError = validate(
      name: name,
      email: email,
      password: password,
    );
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = RegisterRequest(
      email: email.trim(),
      pass: password,
      role: _selectedRole ?? 'pembeli',
      namaLengkap: name.trim(),
      nomorTelepon: phone?.trim(),
      alamatLengkap: address?.trim(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
      formattedAddress: address?.trim(),
    );

    final response = await AuthService.register(
      request,
      profilePhoto: _profilePhoto,
    );

    _isLoading = false;

    if (response.success) {
      _registrationSuccess = true;
      // TODO: Store token if returned
      // if (response.token != null) ApiClient.setToken(response.token!);
    } else {
      _errorMessage = response.message ?? 'Registrasi gagal.';
    }

    notifyListeners();
  }
}
