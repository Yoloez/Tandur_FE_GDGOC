/// Full model for the AI price analysis response from POST /products/analyze-price.
class PriceAnalysisResult {
  final String productDetected;
  final EstimatedPrice estimatedPrice;
  final QualityInfo quality;
  final VisualAnalysis visualAnalysis;
  final double confidenceScore;
  final List<String> reasoning;
  final Recommendation recommendation;

  const PriceAnalysisResult({
    required this.productDetected,
    required this.estimatedPrice,
    required this.quality,
    required this.visualAnalysis,
    required this.confidenceScore,
    required this.reasoning,
    required this.recommendation,
  });

  factory PriceAnalysisResult.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return PriceAnalysisResult(
      productDetected: data['productDetected']?.toString() ?? '',
      estimatedPrice: EstimatedPrice.fromJson(
          (data['estimatedPrice'] as Map<String, dynamic>?) ?? {}),
      quality: QualityInfo.fromJson(
          (data['quality'] as Map<String, dynamic>?) ?? {}),
      visualAnalysis: VisualAnalysis.fromJson(
          (data['visualAnalysis'] as Map<String, dynamic>?) ?? {}),
      confidenceScore:
          (data['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      reasoning: (data['reasoning'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recommendation: Recommendation.fromJson(
          (data['recommendation'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class EstimatedPrice {
  final int min;
  final int max;
  final String currency;

  const EstimatedPrice(
      {required this.min, required this.max, required this.currency});

  factory EstimatedPrice.fromJson(Map<String, dynamic> json) {
    return EstimatedPrice(
      min: json['min'] as int? ?? 0,
      max: json['max'] as int? ?? 0,
      currency: json['currency']?.toString() ?? 'IDR',
    );
  }
}

class QualityInfo {
  final String grade;
  final int score;
  final String freshness;
  final String ripeness;
  final String condition;

  const QualityInfo({
    required this.grade,
    required this.score,
    required this.freshness,
    required this.ripeness,
    required this.condition,
  });

  factory QualityInfo.fromJson(Map<String, dynamic> json) {
    return QualityInfo(
      grade: json['grade']?.toString() ?? '-',
      score: json['score'] as int? ?? 0,
      freshness: json['freshness']?.toString() ?? '-',
      ripeness: json['ripeness']?.toString() ?? '-',
      condition: json['condition']?.toString() ?? '-',
    );
  }
}

class VisualAnalysis {
  final String color;
  final String surfaceCondition;
  final String shapeConsistency;
  final bool damageDetected;
  final bool moldDetected;

  const VisualAnalysis({
    required this.color,
    required this.surfaceCondition,
    required this.shapeConsistency,
    required this.damageDetected,
    required this.moldDetected,
  });

  factory VisualAnalysis.fromJson(Map<String, dynamic> json) {
    return VisualAnalysis(
      color: json['color']?.toString() ?? '-',
      surfaceCondition: json['surfaceCondition']?.toString() ?? '-',
      shapeConsistency: json['shapeConsistency']?.toString() ?? '-',
      damageDetected: json['damageDetected'] as bool? ?? false,
      moldDetected: json['moldDetected'] as bool? ?? false,
    );
  }
}

class Recommendation {
  final String sellingCategory;
  final int recommendedPrice;

  const Recommendation(
      {required this.sellingCategory, required this.recommendedPrice});

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      sellingCategory: json['sellingCategory']?.toString() ?? '-',
      recommendedPrice: json['recommendedPrice'] as int? ?? 0,
    );
  }
}
