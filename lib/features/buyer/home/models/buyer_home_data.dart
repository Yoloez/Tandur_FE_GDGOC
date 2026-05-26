import 'package:flutter/material.dart';

/// A category item (Sayuran, Buah, Beras, Bumbu).
class CategoryItem {
  final String id;
  final String label;

  const CategoryItem({required this.id, required this.label});

  IconData get icon {
    final lower = label.toLowerCase();
    if (lower.contains('sayur')) return Icons.eco_rounded;
    if (lower.contains('buah')) return Icons.apple_rounded;
    if (lower.contains('beras') || lower.contains('biji')) return Icons.grain_rounded;
    if (lower.contains('bumbu') || lower.contains('rempah')) return Icons.spa_rounded;
    if (lower.contains('daging')) return Icons.set_meal_rounded;
    return Icons.category_rounded;
  }

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id']?.toString() ?? '',
      label: json['nama']?.toString() ?? 'Kategori',
    );
  }
}

/// A verified farmer card.
class FarmerItem {
  final String id;
  final String name;
  final String location;
  final double rating;
  final String? avatarUrl;

  const FarmerItem({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    this.avatarUrl,
  });

  factory FarmerItem.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    
    return FarmerItem(
      id: json['id'] ?? '',
      name: profile['namaLengkap'] ?? 'Petani Tanpa Nama',
      location: loc['formattedAddress']?.toString().isNotEmpty == true 
          ? loc['formattedAddress'] 
          : 'Lokasi tidak diketahui',
      rating: 5.0, // Hardcoded since API doesn't provide rating
      avatarUrl: profile['fotoProfil'],
    );
  }
}

/// A product card in the "Produk Segar" grid.
class ProductItem {
  final String id;
  final String farmName;
  final String productName;
  final String priceFormatted;
  final String? badge; // "Organic", "Premium", "Hydroponic", etc.
  final String image;
  final String? tipeStok; // e.g. "kg", "ikat"

  const ProductItem({
    required this.id,
    required this.farmName,
    required this.productName,
    required this.priceFormatted,
    this.badge,
    required this.image,
    this.tipeStok,
  });
}
