import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
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
}