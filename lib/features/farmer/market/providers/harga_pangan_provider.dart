import 'package:flutter/material.dart';
import '../models/harga_pangan_models.dart';
import '../services/harga_pangan_service.dart';

/// Provider for the farmer market (harga pangan) screen.
class HargaPanganProvider extends ChangeNotifier {
  // ── Filter data ──
  List<Province> _provinces = [];
  List<MarketType> _marketTypes = [];
  bool _isLoadingFilters = true;
  String? _filtersError;

  Province? _selectedProvince;
  MarketType? _selectedMarketType;

  // ── Price data ──
  PriceResponse? _priceResponse;
  bool _isLoadingPrices = false;
  String? _pricesError;

  // ── Getters ──
  List<Province> get provinces => _provinces;
  List<MarketType> get marketTypes => _marketTypes;
  bool get isLoadingFilters => _isLoadingFilters;
  String? get filtersError => _filtersError;

  Province? get selectedProvince => _selectedProvince;
  MarketType? get selectedMarketType => _selectedMarketType;

  PriceResponse? get priceResponse => _priceResponse;
  bool get isLoadingPrices => _isLoadingPrices;
  String? get pricesError => _pricesError;

  /// Load provinces + market types in parallel, then auto-fetch prices.
  Future<void> loadFilters() async {
    _isLoadingFilters = true;
    _filtersError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        HargaPanganService.fetchProvinces(),
        HargaPanganService.fetchMarketTypes(),
      ]);

      _provinces = results[0] as List<Province>;
      _marketTypes = results[1] as List<MarketType>;

      // Default selections
      if (_provinces.isNotEmpty) _selectedProvince = _provinces.first;
      if (_marketTypes.isNotEmpty) _selectedMarketType = _marketTypes.first;
    } catch (e) {
      _filtersError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }

    // Auto-fetch prices with default selections
    if (_selectedProvince != null && _selectedMarketType != null) {
      await loadPrices();
    }
  }

  void setProvince(Province? province) {
    if (_selectedProvince?.id == province?.id) return;
    _selectedProvince = province;
    notifyListeners();
    loadPrices();
  }

  void setMarketType(MarketType? type) {
    if (_selectedMarketType?.id == type?.id) return;
    _selectedMarketType = type;
    notifyListeners();
    loadPrices();
  }

  Future<void> loadPrices() async {
    if (_selectedProvince == null || _selectedMarketType == null) return;

    _isLoadingPrices = true;
    _pricesError = null;
    notifyListeners();

    try {
      _priceResponse = await HargaPanganService.fetchPrices(
        provinceId: _selectedProvince!.id,
        marketTypeId: _selectedMarketType!.id,
      );
    } catch (e) {
      _pricesError = e.toString().replaceFirst('Exception: ', '');
      _priceResponse = null;
    } finally {
      _isLoadingPrices = false;
      notifyListeners();
    }
  }
}
