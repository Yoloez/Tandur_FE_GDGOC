import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/features/auth/providers/auth_provider.dart';
import 'package:tandur/core/widgets/edit_profile_screen.dart'
    as tandur_edit_profile;

class SharedProfileScreen extends StatefulWidget {
  const SharedProfileScreen({super.key});

  @override
  State<SharedProfileScreen> createState() => _SharedProfileScreenState();
}

class _SharedProfileScreenState extends State<SharedProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (AuthProvider.instance.currentUser == null) {
      AuthProvider.instance.fetchCurrentUser();
    }
  }

  Future<void> _onLogoutConfirmed() async {
    await AuthProvider.instance.logout();
    if (mounted) context.goNamed(AppRoutes.welcome);
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => _LogoutDialog(onConfirm: _onLogoutConfirmed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthProvider.instance,
      builder: (context, _) {
        final user = AuthProvider.instance.currentUser;
        final avatarUrl = AuthProvider.instance.avatarUrl;
        final email = AuthProvider.instance.userEmail ?? '';
        final name = user?.namaLengkap.trim() ?? '';
        final initials = _buildInitials(name, email);
        final role = user?.role ?? AuthProvider.instance.userRole ?? '';
        final roleLabel = role == 'petani' ? 'Petani' : 'Pembeli';
        final isPetani = role == 'petani';

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              isPetani ? 'Profil Petani' : 'Profil Pembeli',
              style: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Perbarui',
                onPressed: AuthProvider.instance.fetchCurrentUser,
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Avatar + Name + Badge ──
                  _AvatarSection(
                    name: name.isNotEmpty ? name : roleLabel,
                    initials: initials,
                    avatarUrl: avatarUrl,
                    roleLabel: '$roleLabel Terverifikasi',
                    isPetani: isPetani,
                  ),

                  const SizedBox(height: 32),

                  // ── Loading ──
                  if (AuthProvider.instance.isLoading && user == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                  // ── Info Rows ──
                  if (user != null) ...[
                    _InfoCard(
                      icon: Icons.person_outline_rounded,
                      label: 'NAMA LENGKAP',
                      value: name.isNotEmpty ? name : '-',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.mail_outline_rounded,
                      label: 'EMAIL',
                      value: email.isNotEmpty ? email : '-',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.phone_outlined,
                      label: 'NOMOR TELEPON',
                      value: user.nomorTelepon?.isNotEmpty == true
                          ? user.nomorTelepon!
                          : 'Belum diisi',
                      isPlaceholder: !(user.nomorTelepon?.isNotEmpty == true),
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'ALAMAT PENGIRIMAN',
                      value: user.alamatLengkap?.isNotEmpty == true
                          ? user.alamatLengkap!
                          : 'Belum diisi',
                      isPlaceholder: !(user.alamatLengkap?.isNotEmpty == true),
                    ),

                    // ── Stats khusus Petani ──
                    if (isPetani) ...[
                      const SizedBox(height: 12),
                      _PetaniStatsCard(
                        totalProduk: '8', // Placeholder
                        rating: '5.0', // Placeholder
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],

                  // ── Action Buttons ──
                  _EditProfileButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const tandur_edit_profile.EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _LogoutButton(onTap: _showLogoutDialog),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildInitials(String name, String email) {
    if (name.isNotEmpty) {
      final words = name.trim().split(RegExp(r'\s+'));
      return words.take(2).map((w) => w[0].toUpperCase()).join();
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }
}

// ─────────────────────────────────────────────
// Avatar Section (tengah halaman)
// ─────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  final String name;
  final String initials;
  final String? avatarUrl;
  final String roleLabel;
  final bool isPetani;

  const _AvatarSection({
    required this.name,
    required this.initials,
    required this.avatarUrl,
    required this.roleLabel,
    required this.isPetani,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar dengan badge edit
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const tandur_edit_profile.EditProfileScreen(),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          initials,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Nama
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.beVietnamPro(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        // Badge role
        Text(
          roleLabel,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Info Card (masing-masing terpisah)
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.bggreen,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isPlaceholder
                        ? Colors.grey[400]
                        : const Color(0xFF1A1A1A),
                    fontStyle: isPlaceholder
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stats Card khusus Petani
// ─────────────────────────────────────────────
class _PetaniStatsCard extends StatelessWidget {
  final String totalProduk;
  final String rating;

  const _PetaniStatsCard({required this.totalProduk, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.grey[400]!,
              value: totalProduk,
              label: 'TOTAL PRODUK',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          Expanded(
            child: _StatItem(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFFBBC04),
              value: rating,
              label: 'RATING',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppColors.bggreen,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[400],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Logout Button
// ─────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainer,
          foregroundColor: Colors.white,
          // elevation: 0,
          side: const BorderSide(color: AppColors.surfaceVariant, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
          color: AppColors.onBackground,
        ),
        label: Text(
          'Keluar',
          style: GoogleFonts.beVietnamPro(
            color: AppColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Edit Profile Button
// ─────────────────────────────────────────────
class _EditProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.edit_rounded, size: 16),
        label: Text(
          'Edit Profil',
          style: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Logout Dialog
// ─────────────────────────────────────────────
class _LogoutDialog extends StatefulWidget {
  final Future<void> Function() onConfirm;
  const _LogoutDialog({required this.onConfirm});

  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _loading = true);
    await widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Illustration + close button ──
                Stack(
                  children: [
                    // Illustration
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 170,
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/images/logout-illustration.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _loading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Content ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 15, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Apakah kamu ingin keluar?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Subtitle
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFF777777),
                            height: 1.55,
                          ),
                          children: const [
                            TextSpan(
                              text:
                                  'Kamu bisa masuk kembali kapan saja. Data dan riwayat pesananmu tetap tersimpan dengan aman.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Buttons ──
                      Row(
                        children: [
                          // Cancel
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _loading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF333333),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF333333,
                                  ).withValues(alpha: 0.2),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Batal',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.5,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Log out
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Keluar',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
