/// Represents one category from GET /categories.
class ProductCategory {
  final String id;
  final String nama;
  final String? deskripsi;

  const ProductCategory({
    required this.id,
    required this.nama,
    this.deskripsi,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
    );
  }
}
