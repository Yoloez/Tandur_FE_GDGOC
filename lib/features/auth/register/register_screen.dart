import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/core/utils/image_picker_helper.dart';
import 'package:tandur/core/widgets/location_picker_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _provider = RegisterProvider();
    _provider.addListener(_onProviderUpdate);
    _addressController.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      final text = _addressController.text.trim();
      if (text.isNotEmpty && mounted) {
        try {
          List<Location> locations = await locationFromAddress(text);
          if (locations.isNotEmpty) {
            final loc = locations.first;
            _provider.setLocation(LatLng(loc.latitude, loc.longitude));
          }
        } catch (e) {
          // Silent catch for geocoding failures
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

  Future<void> _pickProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await ImagePickerHelper.pickImage(
                  source: ImageSource.camera,
                );
                if (file != null) _provider.setProfilePhoto(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final file = await ImagePickerHelper.pickImage(
                  source: ImageSource.gallery,
                );
                if (file != null) _provider.setProfilePhoto(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _provider.selectedLocation ?? const LatLng(-6.200000, 106.816666),
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final loc = result['location'] as LatLng?;
      final address = result['address'] as String?;
      
      if (loc != null) {
        _provider.setLocation(loc);
      }
      if (address != null && address.isNotEmpty) {
        _addressController.text = address;
      }
    }
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
                        profilePhoto: _provider.profilePhoto,
                        onPickPhoto: _pickProfilePhoto,
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
                        selectedLocation: _provider.selectedLocation,
                        onPickLocation: _pickLocation,
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
