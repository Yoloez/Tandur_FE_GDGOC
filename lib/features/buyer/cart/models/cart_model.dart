/// Cart item model matching backend response from GET /cart.
///
/// Each cart item contains a nested [product] object from the API.
class CartItem {
  final String id; // cart entry ID
  final String pembeliId;
  final String productId;
  int jumlah;
  final bool isCheckout;
  final String? updatedAt;

  // Nested product data
  final CartProduct product;

  CartItem({
    required this.id,
    required this.pembeliId,
    required this.productId,
    required this.jumlah,
    required this.isCheckout,
    this.updatedAt,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      pembeliId: json['pembeliId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      jumlah: (json['jumlah'] as num?)?.toInt() ?? 1,
      isCheckout: json['isCheckout'] == true,
      updatedAt: json['updatedAt']?.toString(),
      product: CartProduct.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Product data nested inside a cart item.
class CartProduct {
  final String id;
  final String petaniId;
  final String namaProduk;
  final String kategoriId;
  final String deskripsi;
  final int? harga; // null = harga belum diatur
  final String tipeStok;
  final int stok;
  final String fotoUrl; // first URL from the list
  final String status;
  final String? createdAt;

  const CartProduct({
    required this.id,
    required this.petaniId,
    required this.namaProduk,
    required this.kategoriId,
    required this.deskripsi,
    this.harga,
    required this.tipeStok,
    required this.stok,
    required this.fotoUrl,
    required this.status,
    this.createdAt,
  });

  /// Formatted price string. Falls back to "-" when harga is null.
  String get priceFormatted {
    if (harga == null) return 'Rp -';
    return 'Rp ${_formatNumber(harga!)}';
  }

  static String _formatNumber(int n) {
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

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    // fotoUrl is now a List<dynamic>
    String fotoUrl = '';
    final rawFoto = json['fotoUrl'];
    if (rawFoto is List && rawFoto.isNotEmpty) {
      fotoUrl = rawFoto.first?.toString() ?? '';
    } else if (rawFoto is String) {
      fotoUrl = rawFoto;
    }

    // harga may be null or a numeric string
    int? harga;
    final rawHarga = json['harga'];
    if (rawHarga != null) {
      harga = int.tryParse(rawHarga.toString()) ??
          double.tryParse(rawHarga.toString())?.toInt();
    }

    return CartProduct(
      id: json['id']?.toString() ?? '',
      petaniId: json['petaniId']?.toString() ?? '',
      namaProduk: json['namaProduk']?.toString() ?? 'Produk',
      kategoriId: json['kategoriId']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      harga: harga,
      tipeStok: json['tipeStok']?.toString() ?? '',
      stok: (json['stok'] as num?)?.toInt() ?? 0,
      fotoUrl: fotoUrl,
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }
}
