// Data models for the farmer's product management screen.
//
// When integrating with API, add factory constructors:
//   factory ManagedProduct.fromJson(Map<String, dynamic> json) { ... }

/// Summary statistics for the product inventory.
class ProductStats {
  final int totalProducts;
  final int lowStock;
  final int active;
  final int outOfStock;

  const ProductStats({
    required this.totalProducts,
    required this.lowStock,
    required this.active,
    required this.outOfStock,
  });

  /// TODO: Replace with API parsing
  // factory ProductStats.fromJson(Map<String, dynamic> json) {
  //   return ProductStats(
  //     totalProducts: json['total_products'],
  //     lowStock: json['low_stock'],
  //     active: json['active'],
  //     outOfStock: json['out_of_stock'],
  //   );
  // }
}

/// A single product managed by the farmer.
class ManagedProduct {
  final String id;
  final String name;
  final String origin;
  final String priceFormatted;
  final String unit; // "kg", "ikat", etc.
  final int stock;
  final String stockUnit; // "kg", "ikat", etc.
  final String image;
  final ProductStatus status;
  final String category; // "sayur", "benih", etc.

  const ManagedProduct({
    required this.id,
    required this.name,
    required this.origin,
    required this.priceFormatted,
    required this.unit,
    required this.stock,
    required this.stockUnit,
    required this.image,
    required this.status,
    required this.category,
  });

  bool get isOutOfStock => status == ProductStatus.outOfStock;

  factory ManagedProduct.fromJson(Map<String, dynamic> json) {
    final stockValue = int.tryParse(json['stok']?.toString() ?? '') ?? 0;
    final categoryValue = (json['kategori'] ?? '').toString().toLowerCase();
    
    // Parse status from JSON
    final statusString = json['status']?.toString().toLowerCase() ?? 'active';
    ProductStatus status;
    if (statusString == 'pending') {
      status = ProductStatus.pending;
    } else if (stockValue <= 0) {
      status = ProductStatus.outOfStock;
    } else {
      status = ProductStatus.active;
    }

    return ManagedProduct(
      id: json['id']?.toString() ?? '',
      name: json['namaProduk']?.toString() ?? '-',
      origin: 'Produk Anda',
      // TODO: backend belum siap, aktifkan saat field harga tersedia
      priceFormatted: 'Rp -',
      unit: 'unit',
      stock: stockValue,
      stockUnit: 'unit',
      image: json['fotoUrl']?.toString() ?? '',
      status: status,
      category: categoryValue.isEmpty ? 'lainnya' : categoryValue,
    );
  }
}

enum ProductStatus { active, pending, outOfStock }
