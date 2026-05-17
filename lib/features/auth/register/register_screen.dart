import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'providers/register_provider.dart';
import 'widgets/role_selection_step.dart';
import 'widgets/register_form_step.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterProvider _provider;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _provider = RegisterProvider();
    _provider.addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _provider.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onProviderUpdate() {
    if (!mounted) return;
    setState(() {});

    // Navigate on success
    if (_provider.registrationSuccess) {
      final route = _provider.selectedRole == 'petani'
          ? AppRoutes.farmerHome
          : AppRoutes.buyerHome;
      context.goNamed(route);
    }
  }

  void _onRegister() {
    _provider.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            _buildTopBar(),

            // ── Content ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: !_provider.hasRole
                    ? RoleSelectionStep(
                        key: const ValueKey('role'),
                        onRoleSelected: _provider.selectRole,
                      )
                    : RegisterFormStep(
                        key: const ValueKey('form'),
                        roleLabel: _provider.roleLabel,
                        selectedRole: _provider.selectedRole!,
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        phoneController: _phoneController,
                        addressController: _addressController,
                        obscurePassword: _obscurePassword,
                        onTogglePassword: () {
                          setState(
                            () => _obscurePassword = !_obscurePassword,
                          );
                        },
                        onRegister: _onRegister,
                        onNavigateToLogin: () => context.pop(),
                        isLoading: _provider.isLoading,
                        errorMessage: _provider.errorMessage,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_provider.hasRole) {
                _provider.clearRole();
              } else {
                context.pop();
              }
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurface,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Tandur',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
