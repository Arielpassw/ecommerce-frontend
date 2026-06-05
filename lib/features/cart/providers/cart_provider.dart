import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service = CartService();

  bool isLoading = false;

  List<CartItemModel> items = [];

  Future<void> loadCart() async {
    try {
      isLoading = true;
      notifyListeners();

      items = _sortItems(await _service.getCart());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(
    String productId,
  ) async {
    await _service.addToCart(
      productId: productId,
      quantity: 1,
    );

    await loadCart();
  }

  Future<void> removeItem(
    String cartItemId,
  ) async {
    await _service.removeItem(
      cartItemId,
    );

    await loadCart();
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    final index = items.indexWhere((item) => item.id == cartItemId);

    if (index != -1) {
      items[index] = items[index].copyWith(quantity: quantity);
      items = _sortItems(items);
      notifyListeners();
    }

    await _service.updateItemQuantity(cartItemId: cartItemId, quantity: quantity);

    await loadCart();
  }

  Future<void> clearCart() async {
    await _service.clearCart();

    items = [];

    notifyListeners();
  }

  double get total {
    double value = 0;

    for (final item in items) {
      value +=
          item.product.price * item.quantity;
    }

    return value;
  }

  List<CartItemModel> _sortItems(List<CartItemModel> values) {
    final sorted = [...values];

    sorted.sort((a, b) {
      final nameCompare = a.product.name.compareTo(b.product.name);
      if (nameCompare != 0) return nameCompare;

      return a.id.compareTo(b.id);
    });

    return sorted;
  }
}
