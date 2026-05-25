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
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: _LogoutDialog(onConfirm: _onLogoutConfirmed),
      ),
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
                        totalProduk: '12', // Placeholder
                        rating: '4.8', // Placeholder
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
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          side: const BorderSide(color: AppColors.error, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
          color: AppColors.error,
        ),
        label: Text(
          'Keluar',
          style: GoogleFonts.beVietnamPro(
            color: AppColors.error,
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
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
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
    return ScaleTransition(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Keluar dari Akun?',
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu akan keluar dari sesi ini.\nPastikan semua data telah tersimpan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              // crossAxisAlignment memastikan kedua tombol memiliki lebar penuh yang sama
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: const Color(0xFFE53935),
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          'Ya, Keluar',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
                const SizedBox(height: 12), // Jarak vertikal antar tombol
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
