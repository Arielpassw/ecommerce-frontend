import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/admin_category_model.dart';

class AdminCategoryService {
  final Dio dio = DioClient.dio;

  Future<Options> _authOptions() async {
    final token = await StorageService.getToken();

    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<List<AdminCategoryModel>> getCategories() async {
    final response = await dio.get('/categories');
    final List data = response.data;

    return data.map((item) => AdminCategoryModel.fromJson(item)).toList();
  }

  Future<AdminCategoryModel> createCategory({
    required String name,
    String? description,
  }) async {
    final response = await dio.post(
      '/categories',
      data: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      options: await _authOptions(),
    );

    return AdminCategoryModel.fromJson(response.data);
  }

  Future<AdminCategoryModel> updateCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    final response = await dio.patch(
      '/categories/$id',
      data: {'name': name, if (description != null) 'description': description},
      options: await _authOptions(),
    );

    return AdminCategoryModel.fromJson(response.data);
  }

  Future<void> deleteCategory(String id) async {
    await dio.delete('/categories/$id', options: await _authOptions());
  }
}
