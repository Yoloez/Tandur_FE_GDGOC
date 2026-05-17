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

  /// TODO: Replace with API parsing
  // factory ManagedProduct.fromJson(Map<String, dynamic> json) {
  //   return ManagedProduct(
  //     id: json['id'],
  //     name: json['name'],
  //     origin: json['origin'],
  //     priceFormatted: 'Rp ${json['price']}',
  //     unit: json['unit'],
  //     stock: json['stock'],
  //     stockUnit: json['stock_unit'],
  //     image: json['image_url'],
  //     status: ProductStatus.values.byName(json['status']),
  //     category: json['category'],
  //   );
  // }
}

enum ProductStatus { active, outOfStock }
