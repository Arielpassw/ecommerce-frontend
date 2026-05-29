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

      items = await _service.getCart();
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
}