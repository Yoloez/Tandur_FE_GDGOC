import 'package:flutter/material.dart';
import '../models/buyer_home_data.dart';

/// Provides mock data for the buyer home screen.
///
/// In production, replace with API calls.
class BuyerHomeProvider extends ChangeNotifier {
  String get location => 'Jakarta Selatan';

  // ── Categories ──
  List<CategoryItem> get categories => const [
    CategoryItem(icon: Icons.eco_rounded, label: 'Sayuran'),
    CategoryItem(icon: Icons.apple_rounded, label: 'Buah'),
    CategoryItem(icon: Icons.grain_rounded, label: 'Beras'),
    CategoryItem(icon: Icons.spa_rounded, label: 'Bumbu'),
  ];

  // ── Verified farmers ──
  List<FarmerItem> get farmers => const [
    FarmerItem(name: 'Pak Budi', location: 'Malang, Jatim', rating: 4.9),
    FarmerItem(name: 'Ibu Sari', location: 'Lembang, Jabar', rating: 4.8),
    FarmerItem(name: 'Mas Hendra', location: 'Karawang, Jabar', rating: 4.7),
  ];

  // ── Fresh products ──
  List<ProductItem> get products => const [
    ProductItem(
      id: 'bayam-hijau',
      farmName: 'Highland Farm',
      productName: 'Bayam Hijau Segar 250g',
      priceFormatted: 'Rp8.500',
      badge: 'Organic',
      image: 'assets/images/onboarding_farm.jpg',
    ),
    ProductItem(
      id: 'apel-fuji',
      farmName: 'Kebun Apel Batu',
      productName: 'Apel Fuji Manis 1kg',
      priceFormatted: 'Rp32.000',
      badge: 'Premium',
      image: 'assets/images/onboarding_market.jpg',
    ),
    ProductItem(
      id: 'ubi-cilembu',
      farmName: 'Tani Maju',
      productName: 'Ubi Cilembu Madu 500g',
      priceFormatted: 'Rp12.000',
      badge: null,
      image: 'assets/images/onboarding_tech.jpg',
    ),
    ProductItem(
      id: 'wortel-organik',
      farmName: 'Green Leaf Farm',
      productName: 'Wortel Organik 500g',
      priceFormatted: 'Rp15.000',
      badge: 'Hydroponic',
      image: 'assets/images/onboarding_farm.jpg',
    ),
  ];
}
