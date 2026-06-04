import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/storage/storage_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthProvider() {
    checkSession();
  }

  bool isLoading = false;
  bool isAuthenticated = false;
  String? role;

  bool get isAdmin => role == 'ADMIN';

  Future<void> checkSession() async {
    final token = await StorageService.getToken();
    isAuthenticated = token != null;
    role = token == null ? null : _readRoleFromToken(token);
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
      role = _readRoleFromToken(response.token);
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
    role = null;
    notifyListeners();
  }

  String? _readRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload) as Map<String, dynamic>;

      return data['role'] as String?;
    } catch (_) {
      return null;
    }
  }
}
