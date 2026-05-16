import 'package:flutter/material.dart';

/// Represents a single onboarding slide content.
class OnboardingItem {
  final String image;
  final String title;
  final String description;

  const OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Represents a selectable role in the role-selection onboarding step.
class RoleOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const RoleOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

// ── Onboarding slide data ──
const List<OnboardingItem> onboardingContents = [
  OnboardingItem(
    image: 'assets/images/onboarding_farm.jpg',
    title: 'Jual Hasil Tani Langsung',
    description:
        'Hubungkan petani dan pembeli secara langsung tanpa perantara untuk harga yang lebih adil.',
  ),
  OnboardingItem(
    image: 'assets/images/onboarding_market.jpg',
    title: 'Produk Segar & Berkualitas',
    description:
        'Dapatkan hasil tani segar langsung dari kebun ke meja makan Anda setiap hari.',
  ),
  OnboardingItem(
    image: 'assets/images/onboarding_tech.jpg',
    title: 'Teknologi untuk Pertanian',
    description:
        'Manfaatkan teknologi modern untuk mengelola kebun dan transaksi dengan mudah.',
  ),
];

// ── Role selection data ──
const List<RoleOption> roleOptions = [
  RoleOption(
    id: 'petani',
    title: 'Petani',
    description: 'Jual hasil tani langsung ke pembeli',
    icon: Icons.agriculture_rounded,
  ),
  RoleOption(
    id: 'pembeli',
    title: 'Pembeli',
    description: 'Dapatkan produk tani segar & berkualitas',
    icon: Icons.shopping_basket_rounded,
  ),
];
