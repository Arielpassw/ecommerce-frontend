import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';

import '../models/cart_model.dart';

class CartService {
  final Dio dio = DioClient.dio;

  Future<Options> _authHeaders() async {
    final token =
        await StorageService.getToken();

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<List<CartItemModel>> getCart() async {
    final response = await dio.get(
      '/cart',
      options: await _authHeaders(),
    );

    final List data =
        response.data['items'];

    return data
        .map(
          (item) =>
              CartItemModel.fromJson(item),
        )
        .toList();
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
  }) async {
    await dio.post(
      '/cart/add',
      data: {
        'productId': productId,
        'quantity': quantity,
      },
      options: await _authHeaders(),
    );
  }

  Future<void> removeItem(
    String cartItemId,
  ) async {
    await dio.delete(
      '/cart/item/$cartItemId',
      options: await _authHeaders(),
    );
  }

  Future<void> clearCart() async {
    await dio.delete(
      '/cart/clear',
      options: await _authHeaders(),
    );
  }
}