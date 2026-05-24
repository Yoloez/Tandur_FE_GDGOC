class TransactionModel {
  final String id;
  final String pembeliId;
  final String totalPembayaran;
  final String metodeBayar;
  final String statusPembayaran;
  final String statusPesanan;
  final String? buktiBayarUrl;
  final String createdAt;
  final List<TransactionItemModel> items;

  TransactionModel({
    required this.id,
    required this.pembeliId,
    required this.totalPembayaran,
    required this.metodeBayar,
    required this.statusPembayaran,
    required this.statusPesanan,
    this.buktiBayarUrl,
    required this.createdAt,
    required this.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      pembeliId: json['pembeliId'] ?? '',
      totalPembayaran: json['totalPembayaran'] ?? '0.00',
      metodeBayar: json['metodeBayar'] ?? '',
      statusPembayaran: json['statusPembayaran'] ?? '',
      statusPesanan: json['statusPesanan'] ?? '',
      buktiBayarUrl: json['buktiBayarUrl'],
      createdAt: json['createdAt'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => TransactionItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TransactionItemModel {
  final int id;
  final String transactionId;
  final String productId;
  final int jumlah;
  final String hargaSnapshot;
  final TransactionProductModel product;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.jumlah,
    required this.hargaSnapshot,
    required this.product,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] ?? 0,
      transactionId: json['transactionId'] ?? '',
      productId: json['productId'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      hargaSnapshot: json['hargaSnapshot'] ?? '0',
      product: TransactionProductModel.fromJson(json['product'] ?? {}),
    );
  }
}

class TransactionProductModel {
  final String id;
  final String petaniId;
  final String namaProduk;
  final String kategoriId;
  final String deskripsi;
  final int? harga;
  final String tipeStok;
  final int stok;
  final List<String> fotoUrl;
  final String status;
  final String createdAt;

  TransactionProductModel({
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
    required this.createdAt,
  });

  factory TransactionProductModel.fromJson(Map<String, dynamic> json) {
    return TransactionProductModel(
      id: json['id'] ?? '',
      petaniId: json['petaniId'] ?? '',
      namaProduk: json['namaProduk'] ?? '',
      kategoriId: json['kategoriId'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: json['harga'] != null ? int.tryParse(json['harga'].toString()) : null,
      tipeStok: json['tipeStok'] ?? '',
      stok: json['stok'] ?? 0,
      fotoUrl: (json['fotoUrl'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get priceFormatted {
    if (harga == null) return 'Rp -';
    final s = harga.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }
}
