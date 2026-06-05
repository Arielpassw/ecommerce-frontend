import 'package:flutter/material.dart';

import '../models/product_category_model.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductsService _service = ProductsService();

  bool isLoading = false;
  String? error;
  List<ProductModel> products = [];
  List<ProductCategoryModel> categories = [];
  String? selectedCategoryId;
  String searchQuery = '';

  List<ProductModel> get visibleProducts {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return products;

    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          (product.categoryName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadProducts() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final loadedCategories = await _service.getCategories();
      final loadedProducts = selectedCategoryId == null
          ? await _service.getProducts()
          : await _service.getProductsByCategory(selectedCategoryId!);

      categories = _sortCategories(loadedCategories);
      products = loadedProducts;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String? categoryId) async {
    selectedCategoryId = categoryId;
    await loadProducts();
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  List<ProductCategoryModel> _sortCategories(
    List<ProductCategoryModel> values,
  ) {
    const order = [
      'laptops',
      'smartphone',
      'monitores',
      'audio',
      'gaming',
      'perifericos',
    ];

    int indexFor(ProductCategoryModel category) {
      final name = category.name
          .trim()
          .toLowerCase()
          .replaceAll('\u00E9', 'e');
      final index = order.indexOf(name);

      return index == -1 ? order.length : index;
    }

    final sorted = [...values];

    sorted.sort((a, b) {
      final orderCompare = indexFor(a).compareTo(indexFor(b));
      if (orderCompare != 0) return orderCompare;

      return a.name.compareTo(b.name);
    });

    return sorted;
  }
}
