import 'package:flutter/material.dart';
import '../models/harga_pangan_models.dart';
import '../services/harga_pangan_service.dart';

/// Provider for the farmer market (harga pangan) screen.
class HargaPanganProvider extends ChangeNotifier {
  // ── Filter data ──
  List<Market> _markets = [];
  bool _isLoadingFilters = true;
  String? _filtersError;

  Market? _selectedMarket;

  // ── Price data ──
  PriceResponse? _priceResponse;
  bool _isLoadingPrices = false;
  String? _pricesError;

  // ── Getters ──
  List<Market> get markets => _markets;
  bool get isLoadingFilters => _isLoadingFilters;
  String? get filtersError => _filtersError;

  Market? get selectedMarket => _selectedMarket;

  PriceResponse? get priceResponse => _priceResponse;
  bool get isLoadingPrices => _isLoadingPrices;
  String? get pricesError => _pricesError;

  /// Load markets, then auto-fetch prices.
  Future<void> loadFilters() async {
    _isLoadingFilters = true;
    _filtersError = null;
    notifyListeners();

    try {
      _markets = await HargaPanganService.fetchMarkets();

      // Default selections
      if (_markets.isNotEmpty) _selectedMarket = _markets.first;
    } catch (e) {
      _filtersError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }

    // Auto-fetch prices with default selection
    if (_selectedMarket != null) {
      await loadPrices();
    }
  }

  void setMarket(Market? market) {
    if (_selectedMarket?.id == market?.id) return;
    _selectedMarket = market;
    notifyListeners();
    loadPrices();
  }

  Future<void> loadPrices() async {
    if (_selectedMarket == null) return;

    _isLoadingPrices = true;
    _pricesError = null;
    notifyListeners();

    try {
      _priceResponse = await HargaPanganService.fetchPrices(
        pasarId: _selectedMarket!.id,
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
