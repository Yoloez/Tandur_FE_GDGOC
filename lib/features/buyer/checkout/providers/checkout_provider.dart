import 'package:flutter/material.dart';
import 'package:tandur/features/buyer/checkout/models/transaction_model.dart';
import 'package:tandur/features/buyer/checkout/services/checkout_service.dart';

class CheckoutProvider extends ChangeNotifier {
  static final CheckoutProvider instance = CheckoutProvider._internal();
  factory CheckoutProvider() => instance;
  CheckoutProvider._internal();

  TransactionModel? _transaction;
  bool _isLoading = false;
  String? _errorMessage;

  TransactionModel? get transaction => _transaction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTransaction() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transaction = await CheckoutService.fetchLatestTransaction();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
