import 'package:flutter/material.dart';
import '../models/product_detail_data.dart';

/// Provides product detail data.
///
/// Currently returns mock data. Replace [getProductById] with an API call:
/// ```dart
/// Future<ProductDetail> getProductById(String id) async {
///   final response = await dio.get('/api/products/$id');
///   return ProductDetail.fromJson(response.data);
/// }
/// ```
class ProductDetailProvider extends ChangeNotifier {
  ProductDetail? _product;
  bool _isLoading = false;

  ProductDetail? get product => _product;
  bool get isLoading => _isLoading;

  /// Fetch product detail by ID.
  ///
  /// TODO: Replace with actual API call.
  Future<void> loadProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _product = _mockProducts[productId] ?? _mockProducts.values.first;
    _isLoading = false;
    notifyListeners();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ── Mock data — remove when API is ready ──
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static final Map<String, ProductDetail> _mockProducts = {
    'bayam-hijau': const ProductDetail(
      id: 'bayam-hijau',
      name: 'Bayam Hijau Segar 250g',
      priceFormatted: 'Rp 8.500',
      weight: '250g',
      badge: 'Organic',
      image: 'assets/images/onboarding_farm.jpg',
      description:
          'Bayam hijau segar pilihan dari dataran tinggi Malang. Ditanam dengan metode pertanian berkelanjutan tanpa menggunakan pestisida kimia. Memiliki rasa yang lebih manis dan tekstur renyah yang sempurna untuk jus maupun masakan rumah.',
      farmName: 'Highland Farm',
      farmLocation: 'Malang, Jatim',
      farmRating: 4.9,
      features: ['Organik', 'Bebas Pestisida', 'Panen Hari Ini'],
      healthBenefits: [
        HealthBenefit(label: 'Zat Besi Tinggi', description: 'Mencegah anemia'),
        HealthBenefit(label: 'Vitamin K', description: 'Menjaga kesehatan tulang'),
      ],
      reviews: [
        ReviewItem(
          initials: 'AD',
          name: 'Andi Dermawan',
          stars: 5,
          text: 'Bayamnya segar banget, hijau dan renyah. Cocok buat tumis!',
        ),
        ReviewItem(
          initials: 'MS',
          name: 'Maya S.',
          stars: 4,
          text: 'Recommended farmer. Packing aman, pengiriman cepat.',
        ),
      ],
    ),
    'apel-fuji': const ProductDetail(
      id: 'apel-fuji',
      name: 'Apel Fuji Manis 1kg',
      priceFormatted: 'Rp 32.000',
      weight: '1kg',
      badge: 'Premium',
      image: 'assets/images/onboarding_market.jpg',
      description:
          'Apel Fuji manis langsung dari kebun Batu, Malang. Ukuran besar, warna merah cerah, dan rasa yang sangat manis. Cocok untuk dikonsumsi langsung atau dijadikan jus buah segar.',
      farmName: 'Kebun Apel Batu',
      farmLocation: 'Batu, Malang',
      farmRating: 4.8,
      features: ['Premium', 'Panen Hari Ini'],
      healthBenefits: [
        HealthBenefit(label: 'Serat Tinggi', description: 'Melancarkan pencernaan'),
        HealthBenefit(label: 'Antioksidan', description: 'Meningkatkan imun'),
      ],
      reviews: [
        ReviewItem(
          initials: 'RN',
          name: 'Rina N.',
          stars: 5,
          text: 'Apelnya besar-besar dan manis! Anak-anak suka banget.',
        ),
      ],
    ),
    'ubi-cilembu': const ProductDetail(
      id: 'ubi-cilembu',
      name: 'Ubi Cilembu Madu 500g',
      priceFormatted: 'Rp 12.000',
      weight: '500g',
      badge: null,
      image: 'assets/images/onboarding_tech.jpg',
      description:
          'Ubi Cilembu asli dari Sumedang. Ketika dipanggang mengeluarkan madu alami yang sangat manis. Tekstur lembut dan rasa yang khas, cocok untuk camilan sehat keluarga.',
      farmName: 'Tani Maju',
      farmLocation: 'Sumedang, Jabar',
      farmRating: 4.7,
      features: ['Alami', 'Panen Hari Ini'],
      healthBenefits: [
        HealthBenefit(label: 'Vitamin A Tinggi', description: 'Menjaga kesehatan mata'),
        HealthBenefit(label: 'Karbohidrat Kompleks', description: 'Energi tahan lama'),
      ],
      reviews: [
        ReviewItem(
          initials: 'BK',
          name: 'Budi K.',
          stars: 5,
          text: 'Ubi Cilembu nya legit banget, madu keluar banyak saat dipanggang.',
        ),
      ],
    ),
    'wortel-organik': const ProductDetail(
      id: 'wortel-organik',
      name: 'Wortel Organik 500g',
      priceFormatted: 'Rp 15.000',
      weight: '500g',
      badge: 'Hydroponic',
      image: 'assets/images/onboarding_farm.jpg',
      description:
          'Wortel organik pilihan dari dataran tinggi Malang. Ditanam dengan metode pertanian berkelanjutan tanpa menggunakan pestisida kimia. Memiliki rasa yang lebih manis dan tekstur renyah yang sempurna untuk jus maupun masakan rumah.',
      farmName: 'Green Leaf Farm',
      farmLocation: 'Malang, Jatim',
      farmRating: 4.9,
      features: ['Organik', 'Bebas Pestisida', 'Panen Hari Ini'],
      healthBenefits: [
        HealthBenefit(label: 'Vitamin A Tinggi', description: 'Menjaga kesehatan mata'),
        HealthBenefit(label: 'Antioksidan', description: 'Meningkatkan imun'),
      ],
      reviews: [
        ReviewItem(
          initials: 'AD',
          name: 'Andi Dermawan',
          stars: 5,
          text:
              '"Wortelnya beneran segar banget, pas sampe masih ada sedikit tanah lemabnya. Manis buat dijus."',
        ),
        ReviewItem(
          initials: 'MS',
          name: 'Maya S.',
          stars: 4,
          text: '"Recommended farmer. Packing aman, pengiriman cepat."',
        ),
      ],
    ),
  };
}
