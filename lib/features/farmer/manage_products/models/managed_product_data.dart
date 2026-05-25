// Data models for the farmer's product management screen.

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
}

/// Pagination metadata returned from GET /products/me
class ProductMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProductMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

/// A single product managed by the farmer.
class ManagedProduct {
  final String id;
  final String name;
  final String petaniId;
  final String deskripsi;
  final String priceFormatted;
  final int? harga;
  final String tipeStok; // "kg", "pack", etc.
  final int stok;
  final List<String> fotoUrl;
  final ProductStatus status;
  final String kategoriId;
  final String createdAt;

  const ManagedProduct({
    required this.id,
    required this.name,
    required this.petaniId,
    required this.deskripsi,
    required this.priceFormatted,
    this.harga,
    required this.tipeStok,
    required this.stok,
    required this.fotoUrl,
    required this.status,
    required this.kategoriId,
    required this.createdAt,
  });

  /// Convenience getter: first image URL or empty string.
  String get imageUrl => fotoUrl.isNotEmpty ? fotoUrl.first : '';

  bool get isOutOfStock => stok <= 0;

  factory ManagedProduct.fromJson(Map<String, dynamic> json) {
    final stokValue = (json['stok'] as num?)?.toInt() ?? 0;

    // Parse status
    final statusString = (json['status'] ?? 'active').toString().toLowerCase();
    ProductStatus status;
    switch (statusString) {
      case 'pending':
        status = ProductStatus.pending;
        break;
      case 'non-active':
      case 'nonactive':
      case 'inactive':
        status = ProductStatus.nonActive;
        break;
      case 'active':
      default:
        status = stokValue <= 0 ? ProductStatus.outOfStock : ProductStatus.active;
    }

    // Parse fotoUrl (List<dynamic> from API)
    List<String> fotoUrl = [];
    final rawFoto = json['fotoUrl'];
    if (rawFoto is List) {
      fotoUrl = rawFoto.map((e) => e.toString()).toList();
    } else if (rawFoto is String && rawFoto.isNotEmpty) {
      fotoUrl = [rawFoto];
    }

    // Parse harga (may be null or a numeric string)
    int? harga;
    final rawHarga = json['harga'];
    if (rawHarga != null) {
      harga = int.tryParse(rawHarga.toString()) ??
          double.tryParse(rawHarga.toString())?.toInt();
    }

    return ManagedProduct(
      id: json['id']?.toString() ?? '',
      name: json['namaProduk']?.toString() ?? '-',
      petaniId: json['petaniId']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      priceFormatted: harga != null ? 'Rp ${_fmt(harga)}' : 'Rp -',
      harga: harga,
      tipeStok: json['tipeStok']?.toString() ?? '',
      stok: stokValue,
      fotoUrl: fotoUrl,
      status: status,
      kategoriId: json['kategoriId']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }
}

enum ProductStatus { active, pending, nonActive, outOfStock }
