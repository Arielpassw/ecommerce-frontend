import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  final Dio dio = DioClient.dio;

  Future<Options> _authHeaders() async {
    final token = await StorageService.getToken();

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<UserProfileModel> getProfile() async {
    final response = await dio.get(
      '/users/profile',
      options: await _authHeaders(),
    );

    return UserProfileModel.fromJson(response.data);
  }
}
