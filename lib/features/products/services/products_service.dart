import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';

class ProductsService {
  final Dio dio = DioClient.dio;

  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get('/products');

    final List data = response.data;

    return data
        .map((item) => ProductModel.fromJson(item))
        .toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final response = await dio.get('/products/category/$categoryId');

    final List data = response.data;

    return data.map((item) => ProductModel.fromJson(item)).toList();
  }

  Future<List<ProductCategoryModel>> getCategories() async {
    final response = await dio.get('/categories');

    final List data = response.data;

    return data.map((item) => ProductCategoryModel.fromJson(item)).toList();
  }
}
