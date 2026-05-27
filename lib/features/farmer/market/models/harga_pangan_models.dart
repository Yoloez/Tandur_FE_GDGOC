/// Province item from GET /hargapangan/provinces
class Province {
  final int id;
  final String name;

  const Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['province_id'] as int? ?? 0,
      name: json['province_name']?.toString() ?? '',
    );
  }
}

/// Market type item from GET /hargapangan/market-types
class MarketType {
  final int id;
  final String name;

  const MarketType({required this.id, required this.name});

  factory MarketType.fromJson(Map<String, dynamic> json) {
    return MarketType(
      id: json['price_type_id'] as int? ?? 0,
      name: json['price_type_name']?.toString() ?? '',
    );
  }
}

/// Single commodity price from POST /hargapangan/prices
class CommodityPrice {
  final String commodity;
  final int nominal;
  final int change;
  final double changePercentage;
  final String denomination;
  final String? date;

  const CommodityPrice({
    required this.commodity,
    required this.nominal,
    required this.change,
    required this.changePercentage,
    required this.denomination,
    this.date,
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
    );
  }
}

/// Full price response from POST /hargapangan/prices
class PriceResponse {
  final int provinceId;
  final int marketTypeId;
  final String? updatedAt;
  final List<CommodityPrice> prices;

  const PriceResponse({
    required this.provinceId,
    required this.marketTypeId,
    this.updatedAt,
    required this.prices,
  });

  factory PriceResponse.fromJson(Map<String, dynamic> json) {
    final pricesRaw = json['prices'] as List? ?? [];
    return PriceResponse(
      provinceId: json['provinceId'] as int? ?? 0,
      marketTypeId: json['marketTypeId'] as int? ?? 0,
      updatedAt: json['updatedAt']?.toString(),
      prices: pricesRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CommodityPrice.fromJson(e))
          .toList(),
    );
  }
}
