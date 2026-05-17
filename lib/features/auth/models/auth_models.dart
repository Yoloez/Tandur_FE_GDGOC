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
  final String? noTelp;
  final String? alamat;

  const RegisterRequest({
    required this.email,
    required this.pass,
    required this.role,
    required this.namaLengkap,
    this.noTelp,
    this.alamat,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'email': email,
      'pass': pass,
      'role': role,
      'namaLengkap': namaLengkap,
    };
    if (noTelp != null && noTelp!.isNotEmpty) data['noTelp'] = noTelp;
    if (alamat != null && alamat!.isNotEmpty) data['alamat'] = alamat;
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
