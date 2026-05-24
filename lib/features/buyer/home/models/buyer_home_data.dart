import 'package:flutter/material.dart';

/// A category item (Sayuran, Buah, Beras, Bumbu).
class CategoryItem {
  final IconData icon;
  final String label;

  const CategoryItem({required this.icon, required this.label});
}

/// A verified farmer card.
class FarmerItem {
  final String name;
  final String location;
  final double rating;
  final String? avatarUrl;

  const FarmerItem({
    required this.name,
    required this.location,
    required this.rating,
    this.avatarUrl,
  });
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
