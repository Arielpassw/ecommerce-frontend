import 'package:flutter/material.dart';

import '../../../core/storage/storage_service.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService =
      AuthService();

  bool isLoading = false;

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;

      notifyListeners();

      final response =
          await _authService.login(
        email: email,
        password: password,
      );

      await StorageService.saveToken(
        response.token,
      );
    } finally {
      isLoading = false;

      notifyListeners();
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
      isLoading = true;

      notifyListeners();

      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        age: age,
        email: email,
        password: password,
        passwordConfirmation:
            passwordConfirmation,
      );
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}