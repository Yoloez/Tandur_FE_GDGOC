import 'package:flutter/material.dart';
import 'package:tandur/features/buyer/cart/models/cart_model.dart';
import 'package:tandur/features/buyer/cart/providers/cart_provider.dart';
import 'package:tandur/features/buyer/checkout/services/checkout_service.dart';

class CheckoutProvider extends ChangeNotifier {
  static final CheckoutProvider instance = CheckoutProvider._internal();
  factory CheckoutProvider() => instance;
  CheckoutProvider._internal();

  bool _isSubmitting = false;
  String? _errorMessage;
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  DateTime get pickupDate => _pickupDate;

  /// Gets the selected cart items from CartProvider.
  List<CartItem> get selectedItems => CartProvider.instance.selectedItems;

  /// Gets the farmer info from the first selected item.
  String get petaniId => selectedItems.isNotEmpty
      ? selectedItems.first.product.petaniId
      : '';

  String get namaPetani => selectedItems.isNotEmpty
      ? selectedItems.first.product.namaPetani
      : '';

  String get alamatPetani => selectedItems.isNotEmpty
      ? selectedItems.first.product.alamatPetani
      : '';

  String get fotoPetani => selectedItems.isNotEmpty
      ? selectedItems.first.product.fotoPetani
      : '';

  Map<String, dynamic>? get titikKoordinatPetani => selectedItems.isNotEmpty
      ? selectedItems.first.product.titikKoordinat
      : null;

  /// Calculate total from selected items.
  int get totalHarga => selectedItems.fold(
        0,
        (sum, item) => sum + ((item.product.harga ?? 0) * item.jumlah),
      );

  /// Format currency helper.
  String formatCurrency(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  void setPickupDate(DateTime date) {
    _pickupDate = date;
    notifyListeners();
  }

  /// Submit checkout to API.
  Future<bool> submitCheckout() async {
    if (selectedItems.isEmpty) {
      _errorMessage = 'Tidak ada produk yang dipilih';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = selectedItems.map((item) => {
        'cartId': item.id,
        'productId': item.productId,
        'jumlah': item.jumlah,
        'hargaSatuan': item.product.harga ?? 0,
      }).toList();

      await CheckoutService.checkout(
        petaniId: petaniId,
        tanggalPengambilan: _pickupDate.toUtc().toIso8601String(),
        metodePembayaran: 'COD',
        status: 'pending',
        totalHarga: totalHarga,
        items: items,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
