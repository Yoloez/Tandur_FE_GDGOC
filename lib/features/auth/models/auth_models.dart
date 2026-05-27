/// Data model for the register API request.
///
/// Maps to POST `/auth/register`:
/// ```json
/// {
///   "email": "user@example.com",
///   "pass": "password123",
///   "role": "pembeli",
///   "namaLengkap": "John Doe"
/// }
/// ```
class RegisterRequest {
  final String email;
  final String pass;
  final String role; // "petani" or "pembeli"
  final String namaLengkap;
  final String? nomorTelepon;
  final String? alamatLengkap;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final String? googlePlaceId;

  const RegisterRequest({
    required this.email,
    required this.pass,
    required this.role,
    required this.namaLengkap,
    this.nomorTelepon,
    this.alamatLengkap,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.googlePlaceId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'email': email,
      'pass': pass,
      'role': role,
      'namaLengkap': namaLengkap,
    };
    if (nomorTelepon != null && nomorTelepon!.isNotEmpty) data['nomorTelepon'] = nomorTelepon;
    if (alamatLengkap != null && alamatLengkap!.isNotEmpty) data['alamatLengkap'] = alamatLengkap;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (formattedAddress != null && formattedAddress!.isNotEmpty) data['formattedAddress'] = formattedAddress;
    if (googlePlaceId != null && googlePlaceId!.isNotEmpty) data['googlePlaceId'] = googlePlaceId;
    return data;
  }
}

/// Data model for the login API request.
/// Maps to POST `/auth/login`.
class LoginRequest {
  final String email;
  final String pass;

  const LoginRequest({
    required this.email,
    required this.pass,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'pass': pass,
      };
}

/// Generic auth API response wrapper.
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;

  const AuthResponse({
    required this.success,
    this.message,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Register returns id/email, Login returns access_token
    final bool isSuccess = json['id'] != null || 
                           json['email'] != null || 
                           json['access_token'] != null || 
                           (json['success'] == true);
    
    return AuthResponse(
      success: isSuccess,
      message: json['message'] as String?,
      token: (json['access_token'] ?? json['token']) as String?,
    );
  }
}

/// Data model for the user profile.
class UserModel {
  final String id;
  final String email;
  final String role;
  final String namaLengkap;
  final String? nomorTelepon;
  final String? alamatLengkap;
  final String? fotoProfil;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final String? saldo;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.namaLengkap,
    this.nomorTelepon,
    this.alamatLengkap,
    this.fotoProfil,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.saldo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final location = json['location'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      namaLengkap: profile['namaLengkap'] ?? '',
      nomorTelepon: profile['nomorTelepon'],
      alamatLengkap: profile['alamatLengkap'],
      fotoProfil: profile['fotoProfil'],
      latitude: location['latitude'] != null ? double.tryParse(location['latitude'].toString()) : null,
      longitude: location['longitude'] != null ? double.tryParse(location['longitude'].toString()) : null,
      formattedAddress: location['formattedAddress'],
      saldo: profile['saldo']?.toString(),
    );
  }

  String get saldoFormatted {
    if (saldo == null || saldo!.isEmpty) return 'Rp 0';
    final s = saldo!.split('.').first;
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }
}
