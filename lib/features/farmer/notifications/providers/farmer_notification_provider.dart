import 'package:flutter/material.dart';
import 'package:tandur/features/auth/providers/auth_provider.dart';
import 'package:tandur/features/farmer/notifications/models/farmer_notification_model.dart';
import 'package:tandur/features/farmer/notifications/services/farmer_notification_service.dart';

class FarmerNotificationProvider extends ChangeNotifier {
  static final FarmerNotificationProvider instance = FarmerNotificationProvider._internal();
  factory FarmerNotificationProvider() => instance;
  FarmerNotificationProvider._internal();

  bool _isLoading = false;
  String? _errorMessage;
  List<FarmerTransactionModel> _notifications = [];
  bool _hasFetched = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FarmerTransactionModel> get notifications => _notifications;

  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    if (_hasFetched && !forceRefresh) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allTransactions = await FarmerNotificationService.fetchNotifications();
      final currentFarmerId = AuthProvider.instance.userId;

      if (currentFarmerId == null) {
        _notifications = [];
        return;
      }

      // Filter transactions to only include items for the current farmer
      List<FarmerTransactionModel> filteredTransactions = [];

      for (var transaction in allTransactions) {
        final farmerItems = transaction.items.where((item) {
          return item.product.petaniId == currentFarmerId;
        }).toList();

        if (farmerItems.isNotEmpty) {
          filteredTransactions.add(
            FarmerTransactionModel(
              id: transaction.id,
              pembeliId: transaction.pembeliId,
              petaniId: transaction.petaniId,
              totalPembayaran: transaction.totalPembayaran,
              metodeBayar: transaction.metodeBayar,
              statusPembayaran: transaction.statusPembayaran,
              statusPesanan: transaction.statusPesanan,
              status: transaction.status,
              tanggalPengambilan: transaction.tanggalPengambilan,
              buktiBayarUrl: transaction.buktiBayarUrl,
              createdAt: transaction.createdAt,
              items: farmerItems,
              pembeli: transaction.pembeli,
            ),
          );
        }
      }

      // Sort by newest first
      filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notifications = filteredTransactions;
      _hasFetched = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates status of a transaction and force-refreshes the notifications list.
  Future<void> updateStatus(String id, String status) async {
    await FarmerNotificationService.updateTransactionStatus(id, status);
    _hasFetched = false;
    await fetchNotifications(forceRefresh: true);
  }
}
