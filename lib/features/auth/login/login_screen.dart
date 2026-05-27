import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/features/auth/providers/auth_provider.dart';

/// Login modal sheet — designed to be shown via `showModalBottomSheet`.
///
/// Can also be used as a standalone screen via the `LoginScreen` wrapper below.
class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // Clear any lingering errors from a previous attempt
    AuthProvider.instance.clearError();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Inline validation
    setState(() {
      _emailError = email.isEmpty ? 'Email wajib diisi' : null;
      _passwordError = password.isEmpty ? 'Password wajib diisi' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    final success = await AuthProvider.instance.login(email, password);

    if (success && mounted) {
      Navigator.of(context).pop(); // Dismiss modal

      final role = AuthProvider.instance.userRole;
      if (role == 'petani') {
        context.goNamed(AppRoutes.farmerHome);
      } else {
        context.goNamed(AppRoutes.buyerHome);
      }
    }
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur lupa password belum tersedia.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onGoogleLogin() async {
    final success = await AuthProvider.instance.loginWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pop(); // Dismiss modal

      final role = AuthProvider.instance.userRole;
      if (role == 'petani') {
        context.goNamed(AppRoutes.farmerHome);
      } else {
        context.goNamed(AppRoutes.buyerHome);
      }
    }
  }

  void _onNavigateToRegister() {
    AuthProvider.instance.clearError();
    Navigator.of(context).pop(); // dismiss modal
    context.pushNamed(AppRoutes.register);
  }

  // Future<void> _onDebugLogin(String role) async {
  //   final success = await AuthProvider.instance.debugLogin(role);
  //   if (success && mounted) {
  //     Navigator.of(context).pop();
  //     if (role == 'petani') {
  //       context.goNamed(AppRoutes.farmerHome);
  //     } else {
  //       context.goNamed(AppRoutes.buyerHome);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthProvider.instance,
      builder: (context, _) {
        final authProvider = AuthProvider.instance;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle ──
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Greeting ──
                      Text(
                        'Selamat Datang',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk untuk mulai berbelanja hasil tani terbaik',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Email field ──
                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'nama@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (_) => setState(() => _emailError = null),
                      ),

                      const SizedBox(height: 20),

                      // ── Password field ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Password'),
                          GestureDetector(
                            onTap: _onForgotPassword,
                            child: Text(
                              'Lupa Password?',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        errorText: _passwordError,
                        onChanged: (_) => setState(() => _passwordError = null),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.outline,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ── Error message ──
                      if (authProvider.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],

                      // ── Single Login button ──
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Masuk',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Divider ──
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.outlineVariant),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ATAU MASUK DENGAN',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.outlineVariant),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Google login ──
                      SizedBox(
                        width: double.infinity,
                        child: _SocialButton(
                          label: 'Google',
                          icon: Image.asset(
                            'assets/images/google.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata, size: 24),
                          ),
                          onTap: _onGoogleLogin,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Register link ──
                      Center(
                        child: GestureDetector(
                          onTap: _onNavigateToRegister,
                          child: RichText(
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Daftar',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Legal ──
                      Center(
                        child: Text(
                          'Dengan masuk, Anda menyetujui Ketentuan Layanan\ndan Kebijakan Privasi Tandur.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.outline,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(
              icon,
              color: hasError ? AppColors.error : AppColors.outline,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: hasError
                ? AppColors.errorContainer.withValues(alpha: 0.4)
                : AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.outlineVariant,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...
          [
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 5),
                Text(
                  errorText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
      ],
    );
  }
}

/// Helper to show the login modal from anywhere.
void showLoginModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.5,
      maxChildSize: 0.80,
      builder: (context, scrollController) => const LoginSheet(),
    ),
  );
}

// ── Social button (kept from original) ──
class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standalone screen wrapper — kept for backward compatibility with router.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(child: LoginSheet()),
    );
  }
}
