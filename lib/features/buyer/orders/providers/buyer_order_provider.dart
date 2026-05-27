import 'package:flutter/material.dart';
import 'package:tandur/features/buyer/orders/models/buyer_order_model.dart';
import 'package:tandur/features/buyer/orders/services/buyer_order_service.dart';

class BuyerOrderProvider extends ChangeNotifier {
  static final BuyerOrderProvider instance = BuyerOrderProvider._internal();
  BuyerOrderProvider._internal();

  bool _isLoading = false;
  String? _errorMessage;
  List<BuyerOrderModel> _orders = [];
  bool _hasFetched = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BuyerOrderModel> get orders => _orders;
  bool get hasFetched => _hasFetched;

  Future<void> fetchOrders({bool force = false}) async {
    if (_hasFetched && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOrders = await BuyerOrderService.fetchOrders();
      // Sort by newest first
      fetchedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _orders = fetchedOrders;
      _hasFetched = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
