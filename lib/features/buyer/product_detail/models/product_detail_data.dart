/// Full product detail model — ready for API mapping.
///
/// When integrating with an API, create a `ProductDetail.fromJson(Map<String, dynamic>)`
/// factory constructor to parse the response.
class ProductDetail {
  final String id;
  final String name;
  final String priceFormatted;
  final String weight;
  final String? badge;
  final String image;
  final String description;

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
    required this.weight,
    this.badge,
    required this.image,
    required this.description,
    required this.farmName,
    required this.farmLocation,
    required this.farmRating,
    required this.features,
    required this.healthBenefits,
    required this.reviews,
  });

  /// TODO: Replace with actual API parsing
  // factory ProductDetail.fromJson(Map<String, dynamic> json) {
  //   return ProductDetail(
  //     id: json['id'],
  //     name: json['name'],
  //     ...
  //   );
  // }
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
