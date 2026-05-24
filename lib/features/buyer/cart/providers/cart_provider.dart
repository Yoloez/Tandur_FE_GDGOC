import 'package:flutter/material.dart';
import 'package:tandur/features/buyer/cart/models/cart_model.dart';
import 'package:tandur/features/buyer/cart/services/cart_service.dart';

/// Singleton provider for cart state management.
///
/// All mutations (add, update quantity, delete) are backed by the API
/// and optimistically reflected in the local list.
class CartProvider extends ChangeNotifier {
  static final CartProvider instance = CartProvider._internal();

  factory CartProvider() => instance;

  CartProvider._internal();

  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.jumlah);

  // Real pricing from API (harga per item)
  int get subtotal => _items.fold(
        0,
        (sum, item) => sum + ((item.product.harga ?? 0) * item.jumlah),
      );
  int get totalTagihan => subtotal;

  // ────────────────────────────────────────────────
  // API Operations
  // ────────────────────────────────────────────────

  /// Fetch cart items from backend.
  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await CartService.fetchCart();
      _items
        ..clear()
        ..addAll(result);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a product to cart via POST /cart.
  Future<void> addToCart({
    required String productId,
    required int jumlah,
  }) async {
    await CartService.addToCart(productId: productId, jumlah: jumlah);
    // Refresh the cart from backend to get server-assigned id
    await loadCart();
  }

  /// Update quantity via PATCH /cart/{id}.
  Future<void> updateQuantity(String cartId, int newQuantity) async {
    // Optimistic local update
    final idx = _items.indexWhere((item) => item.id == cartId);
    if (idx != -1) {
      _items[idx].jumlah = newQuantity;
      notifyListeners();
    }

    try {
      await CartService.updateQuantity(cartId: cartId, jumlah: newQuantity);
    } catch (_) {
      // Revert on failure
      await loadCart();
    }
  }

  /// Remove item via DELETE /cart/{id}.
  Future<void> removeItem(String cartId) async {
    // Optimistic local removal
    final removed = _items.where((item) => item.id == cartId).toList();
    _items.removeWhere((item) => item.id == cartId);
    notifyListeners();

    try {
      await CartService.removeFromCart(cartId: cartId);
    } catch (_) {
      // Revert on failure
      _items.addAll(removed);
      notifyListeners();
    }
  }

  /// Increment quantity by 1.
  void incrementQuantity(String cartId) {
    final idx = _items.indexWhere((item) => item.id == cartId);
    if (idx != -1) {
      final newQty = _items[idx].jumlah + 1;
      updateQuantity(cartId, newQty);
    }
  }

  /// Decrement quantity by 1 (minimum 1).
  void decrementQuantity(String cartId) {
    final idx = _items.indexWhere((item) => item.id == cartId);
    if (idx != -1 && _items[idx].jumlah > 1) {
      final newQty = _items[idx].jumlah - 1;
      updateQuantity(cartId, newQty);
    }
  }
}
