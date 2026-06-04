import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/admin_product_model.dart';

class AdminProductService {
  final Dio dio = DioClient.dio;

  Future<Options> _authOptions() async {
    final token = await StorageService.getToken();

    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<List<AdminProductModel>> getProducts() async {
    final response = await dio.get('/products');
    final List data = response.data;

    return data.map((item) => AdminProductModel.fromJson(item)).toList();
  }

  Future<AdminProductModel> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    String? imageUrl,
    bool isFeatured = false,
    double? discount,
  }) async {
    final response = await dio.post(
      '/products',
      data: {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'categoryId': categoryId,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        'isFeatured': isFeatured,
        if (discount != null) 'discount': discount,
      },
      options: await _authOptions(),
    );

    return AdminProductModel.fromJson(response.data);
  }

  Future<AdminProductModel> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    String? imageUrl,
    bool? isFeatured,
    double? discount,
  }) async {
    final response = await dio.patch(
      '/products/$id',
      data: {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'categoryId': categoryId,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (isFeatured != null) 'isFeatured': isFeatured,
        if (discount != null) 'discount': discount,
      },
      options: await _authOptions(),
    );

    return AdminProductModel.fromJson(response.data);
  }

  Future<void> deleteProduct(String id) async {
    await dio.delete('/products/$id', options: await _authOptions());
  }
}
