import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/order_model.dart';

class OrdersService {
  final Dio dio = DioClient.dio;

  Future<Options> _authHeaders() async {
    final token = await StorageService.getToken();

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<OrderModel> checkout() async {
    final response = await dio.post(
      '/orders/checkout',
      options: await _authHeaders(),
    );

    return OrderModel.fromJson(response.data);
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final response = await dio.get(
      '/orders/$orderId',
      options: await _authHeaders(),
    );

    return OrderModel.fromJson(response.data);
  }

  Future<List<OrderModel>> getMyOrders() async {
    final response = await dio.get(
      '/orders/my-orders',
      options: await _authHeaders(),
    );

    final List data = response.data;

    return data.map((item) => OrderModel.fromJson(item)).toList();
  }
}
