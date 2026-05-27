/// Market item from GET /hargapangan/markets
class Market {
  final int id;
  final String nama;

  const Market({required this.id, required this.nama});

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'] as int? ?? 0,
      nama: json['nama']?.toString() ?? '',
    );
  }
}

/// Single commodity price from GET /hargapangan/prices?pasarId=X
class CommodityPrice {
  final String commodity;
  final int nominal;
  final int change;
  final double changePercentage;
  final String denomination;
  final String? date;
  final String? market;
  final String? trend;

  const CommodityPrice({
    required this.commodity,
    required this.nominal,
    required this.change,
    required this.changePercentage,
    required this.denomination,
    this.date,
    this.market,
    this.trend,
  });

  factory CommodityPrice.fromJson(Map<String, dynamic> json) {
    return CommodityPrice(
      commodity: json['commodity']?.toString() ?? '',
      nominal: json['nominal'] as int? ?? 0,
      change: json['change'] as int? ?? 0,
      changePercentage:
          (json['changePercentage'] as num?)?.toDouble() ?? 0.0,
      denomination: json['denomination']?.toString() ?? '',
      date: json['date']?.toString(),
      market: json['market']?.toString(),
      trend: json['trend']?.toString(),
    );
  }
}

/// Full price response from GET /hargapangan/prices?pasarId=X
class PriceResponse {
  final String? source;
  final String? updatedAt;
  final List<CommodityPrice> prices;

  const PriceResponse({
    this.source,
    this.updatedAt,
    required this.prices,
  });

  factory PriceResponse.fromJson(Map<String, dynamic> json) {
    final pricesRaw = json['prices'] as List? ?? [];
    return PriceResponse(
      source: json['source']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      prices: pricesRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CommodityPrice.fromJson(e))
          .toList(),
    );
  }
}
