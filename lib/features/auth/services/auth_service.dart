import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

import '../models/login_response.dart';

class AuthService {
  final Dio dio = DioClient.dio;

  // LOGIN
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return LoginResponse.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Login error',
      );
    }
  }

  // REGISTER
  Future<void> register({
    required String firstName,
    required String lastName,
    required int age,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await dio.post(
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
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Register error',
      );
    }
  }
}