/// Request model for POST /products (multipart/form-data).
/// 
/// Note: `files` are attached separately by the service as MultipartFile.
class ProductCreateRequest {
  final String namaProduk;
  final String kategoriId;
  final String deskripsi;
  final int stok;
  final String tipeStok; // 'kg', 'ikat', 'pack', etc.
  final int? harga;

  const ProductCreateRequest({
    required this.namaProduk,
    required this.kategoriId,
    required this.deskripsi,
    required this.stok,
    required this.tipeStok,
    this.harga,
  });

  /// Produces a plain Map (no File entries) for FormData.fromMap.
  /// File fields are appended separately by the service.
  Map<String, dynamic> toFormFields() {
    final data = <String, dynamic>{
      'namaProduk': namaProduk,
      'kategoriId': kategoriId,
      'deskripsi': deskripsi,
      'stok': stok,
      'tipeStok': tipeStok,
    };
    if (harga != null) data['harga'] = harga;
    return data;
  }
}
