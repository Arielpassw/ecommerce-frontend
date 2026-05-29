import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class AuthService {
  final Dio dio = DioClient.dio;

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> register({
    required String firstName,
    required String lastName,
    required int age,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await dio.post(
      '/auth/register',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'age': age,
        'email': email,
        'password': password,
        'password_confirmation':
            passwordConfirmation,
      },
    );
  }
}