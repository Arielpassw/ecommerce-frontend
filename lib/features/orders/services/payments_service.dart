import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';

class PaymentsService {
  final Dio dio = DioClient.dio;

  Future<Options> _authHeaders() async {
    final token = await StorageService.getToken();

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<String> createStripeSession({
    required String orderId,
    required double amount,
  }) async {
    final response = await dio.post(
      '/payments/stripe/create-checkout-session',
      data: {
        'orderId': orderId,
        'amount': amount,
      },
      options: await _authHeaders(),
    );

    return response.data['data']['url'];
  }

  Future<Map<String, dynamic>> createPaypalOrder({
    required String orderId,
    required double amount,
  }) async {
    final response = await dio.post(
      '/payments/paypal/create-order',
      data: {
        'orderId': orderId,
        'amount': amount,
      },
      options: await _authHeaders(),
    );

    return response.data;
  }

  Future<void> capturePaypalOrder({
    required String paypalOrderId,
    required String orderId,
  }) async {
    await dio.post(
      '/payments/paypal/capture-order',
      data: {
        'paypalOrderId': paypalOrderId,
        'orderId': orderId,
      },
      options: await _authHeaders(),
    );
  }
}