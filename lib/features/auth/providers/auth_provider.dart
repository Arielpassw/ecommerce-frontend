import 'package:flutter/material.dart';

import '../../../core/storage/storage_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool isAuthenticated = false;

  Future<void> checkSession() async {
    final token = await StorageService.getToken();
    isAuthenticated = token != null;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authService.login(
        email: email,
        password: password,
      );

      await StorageService.saveToken(response.token);
      isAuthenticated = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await StorageService.removeToken();
    isAuthenticated = false;
    notifyListeners();
  }
}