/// Full product detail model — mapped directly from GET /products/{id}.
class ProductDetail {
  final String id;
  final String name;
  final String priceFormatted;
  final String tipeStok;
  final int stok;
  final String? badge;
  final String image;
  final String description;
  final String status;

  // ── Farmer info ──
  final String farmName;
  final String farmLocation;
  final double farmRating;

  // ── Feature tags ──
  final List<String> features;

  // ── Health benefits ──
  final List<HealthBenefit> healthBenefits;

  // ── Reviews ──
  final List<ReviewItem> reviews;

  const ProductDetail({
    required this.id,
    required this.name,
    required this.priceFormatted,
    required this.tipeStok,
    required this.stok,
    this.badge,
    required this.image,
    required this.description,
    required this.status,
    required this.farmName,
    required this.farmLocation,
    required this.farmRating,
    required this.features,
    required this.healthBenefits,
    required this.reviews,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    // ── Image: fotoUrl is now List<dynamic> ──
    String image = '';
    final fotoUrl = json['fotoUrl'];
    if (fotoUrl is List && fotoUrl.isNotEmpty) {
      image = fotoUrl.first?.toString() ?? '';
    } else if (fotoUrl is String && fotoUrl.isNotEmpty) {
      image = fotoUrl;
    }

    // ── Price ──
    final hargaRaw = json['harga'];
    String priceFormatted;
    if (hargaRaw != null) {
      final hargaNum = double.tryParse(hargaRaw.toString());
      if (hargaNum != null) {
        priceFormatted = 'Rp ${_formatNumber(hargaNum.toInt())}';
      } else {
        priceFormatted = 'Hubungi Petani';
      }
    } else {
      priceFormatted = 'Hubungi Petani';
    }

    // ── tipeStok & stok ──
    final tipeStok = json['tipeStok']?.toString() ?? '';
    final stok = (json['stok'] as num?)?.toInt() ?? 0;

    // ── Badge from kategori / status ──
    final status = json['status']?.toString() ?? '';
    String? badge;
    if (status == 'active') badge = 'Tersedia';

    // ── Features & health benefits (static enrichment) ──
    final features = <String>['Segar', 'Dari Petani Lokal'];
    if (tipeStok == 'kg') features.add('Dijual per kg');
    if (tipeStok == 'ikat') features.add('Dijual per ikat');

    const healthBenefits = <HealthBenefit>[
      HealthBenefit(label: 'Kaya Nutrisi', description: 'Sumber vitamin alami'),
      HealthBenefit(
        label: 'Segar & Alami',
        description: 'Bebas bahan pengawet berbahaya',
      ),
    ];

    return ProductDetail(
      id: json['id']?.toString() ?? '',
      name: json['namaProduk']?.toString() ?? 'Produk Tandur',
      priceFormatted: priceFormatted,
      tipeStok: tipeStok,
      stok: stok,
      badge: badge,
      image: image,
      description:
          json['deskripsi']?.toString() ?? 'Tidak ada deskripsi produk.',
      status: status,
      farmName: 'Mitra Tani Tandur',
      farmLocation: 'Yogyakarta',
      farmRating: 4.8,
      features: features,
      healthBenefits: healthBenefits,
      reviews: const [
        ReviewItem(
          initials: 'MS',
          name: 'Maya Sartika',
          stars: 5,
          text: 'Produknya sangat segar dan kemasannya rapi sekali!',
        ),
      ],
    );
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
}

class HealthBenefit {
  final String label;
  final String description;

  const HealthBenefit({required this.label, required this.description});
}

class ReviewItem {
  final String initials;
  final String name;
  final int stars;
  final String text;

  const ReviewItem({
    required this.initials,
    required this.name,
    required this.stars,
    required this.text,
  });
}
