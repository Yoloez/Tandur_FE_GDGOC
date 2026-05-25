import 'package:flutter/material.dart';

/// A category item (Sayuran, Buah, Beras, Bumbu).
class CategoryItem {
  final IconData icon;
  final String label;

  const CategoryItem({required this.icon, required this.label});
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
