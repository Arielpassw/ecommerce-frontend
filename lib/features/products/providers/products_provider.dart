import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/products_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductsService _service = ProductsService();

  bool isLoading = false;
  String? error;
  List<ProductModel> products = [];

  Future<void> loadProducts() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      products = await _service.getProducts();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}