class BuyerOrderModel {
  final String id;
  final String pembeliId;
  final String? petaniId;
  final String totalPembayaran;
  final String metodeBayar;
  final String statusPembayaran;
  final String statusPesanan;
  final String status;
  final String? tanggalPengambilan;
  final String? buktiBayarUrl;
  final String createdAt;
  final List<BuyerOrderItemModel> items;
  final BuyerOrderFarmerModel? petani;

  BuyerOrderModel({
    required this.id,
    required this.pembeliId,
    this.petaniId,
    required this.totalPembayaran,
    required this.metodeBayar,
    required this.statusPembayaran,
    required this.statusPesanan,
    required this.status,
    this.tanggalPengambilan,
    this.buktiBayarUrl,
    required this.createdAt,
    required this.items,
    this.petani,
  });

  factory BuyerOrderModel.fromJson(Map<String, dynamic> json) {
    return BuyerOrderModel(
      id: json['id']?.toString() ?? '',
      pembeliId: json['pembeliId']?.toString() ?? '',
      petaniId: json['petaniId']?.toString(),
      totalPembayaran: json['totalPembayaran']?.toString() ?? '0',
      metodeBayar: json['metodeBayar']?.toString() ?? '',
      statusPembayaran: json['statusPembayaran']?.toString() ?? '',
      statusPesanan: json['statusPesanan']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      tanggalPengambilan: json['tanggalPengambilan']?.toString(),
      buktiBayarUrl: json['buktiBayarUrl']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      items: (json['items'] as List?)
              ?.map((item) => BuyerOrderItemModel.fromJson(item))
              .toList() ??
          [],
      petani: json['petani'] != null
          ? BuyerOrderFarmerModel.fromJson(json['petani'])
          : null,
    );
  }
}

class BuyerOrderItemModel {
  final int id;
  final String transactionId;
  final String productId;
  final int jumlah;
  final String hargaSnapshot;
  final BuyerOrderProductModel product;

  BuyerOrderItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.jumlah,
    required this.hargaSnapshot,
    required this.product,
  });

  factory BuyerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return BuyerOrderItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      transactionId: json['transactionId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      jumlah: int.tryParse(json['jumlah']?.toString() ?? '') ?? 0,
      hargaSnapshot: json['hargaSnapshot']?.toString() ?? '0',
      product: BuyerOrderProductModel.fromJson(json['product'] ?? {}),
    );
  }
}

class BuyerOrderProductModel {
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

  BuyerOrderProductModel({
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

  factory BuyerOrderProductModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFotoUrls = [];
    if (json['fotoUrl'] is List) {
      parsedFotoUrls = (json['fotoUrl'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['fotoUrl'] is String) {
      parsedFotoUrls = [json['fotoUrl']];
    }
    return BuyerOrderProductModel(
      id: json['id']?.toString() ?? '',
      petaniId: json['petaniId']?.toString() ?? '',
      namaProduk: json['namaProduk']?.toString() ?? '',
      kategoriId: json['kategoriId']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      harga: int.tryParse(json['harga']?.toString() ?? ''),
      tipeStok: json['tipeStok']?.toString() ?? '',
      stok: int.tryParse(json['stok']?.toString() ?? '') ?? 0,
      fotoUrl: parsedFotoUrls,
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class BuyerOrderFarmerModel {
  final String namaLengkap;
  final String nomorTelepon;
  final String? alamatLengkap;
  final BuyerTitikKoordinat? titikKoordinat;

  BuyerOrderFarmerModel({
    required this.namaLengkap,
    required this.nomorTelepon,
    this.alamatLengkap,
    this.titikKoordinat,
  });

  factory BuyerOrderFarmerModel.fromJson(Map<String, dynamic> json) {
    return BuyerOrderFarmerModel(
      namaLengkap: json['namaLengkap']?.toString() ?? 'Petani',
      nomorTelepon: json['nomorTelepon']?.toString() ?? '-',
      alamatLengkap: json['alamatLengkap']?.toString(),
      titikKoordinat: json['titikKoordinat'] != null
          ? BuyerTitikKoordinat.fromJson(json['titikKoordinat'])
          : null,
    );
  }
}

class BuyerTitikKoordinat {
  final String latitude;
  final String longitude;

  BuyerTitikKoordinat({
    required this.latitude,
    required this.longitude,
  });

  factory BuyerTitikKoordinat.fromJson(Map<String, dynamic> json) {
    return BuyerTitikKoordinat(
      latitude: json['latitude']?.toString() ?? '0',
      longitude: json['longitude']?.toString() ?? '0',
    );
  }
}
