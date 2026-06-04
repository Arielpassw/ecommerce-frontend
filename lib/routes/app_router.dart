import 'dart:convert';

import 'package:go_router/go_router.dart';

import '../core/storage/storage_service.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

import '../features/products/screens/home_screen.dart';

import '../features/cart/screens/cart_screen.dart';

import '../features/checkout/screens/checkout_screen.dart';
import '../features/admin_products/screens/admin_categories_screen.dart';
import '../features/admin_products/screens/admin_product_create_screen.dart';
import '../features/admin_products/screens/admin_products_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final isAdminRoute =
        state.uri.path.startsWith('/admin');

    if (!isAdminRoute) return null;

    final token = await StorageService.getToken();
    final isAdmin = token != null && _isAdminToken(token);

    if (token == null) return '/login';
    if (!isAdmin) return '/home';

    return null;
  },

  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/register',

      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),

    GoRoute(
      path: '/checkout',

      builder: (context, state) => const CheckoutScreen(),
    ),

    GoRoute(
      path: '/admin/products',

      builder: (context, state) => const AdminProductsScreen(),
    ),

    GoRoute(
      path: '/admin/products/create',

      builder: (context, state) => const AdminProductCreateScreen(),
    ),

    GoRoute(
      path: '/admin/categories',

      builder: (context, state) => const AdminCategoriesScreen(),
    ),
  ],
);

bool _isAdminToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return false;

    final payload = String.fromCharCodes(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final data = jsonDecode(payload) as Map<String, dynamic>;

    return data['role'] == 'ADMIN';
  } catch (_) {
    return false;
  }
}
