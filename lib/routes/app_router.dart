import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

import '../features/products/screens/home_screen.dart';

import '../features/cart/screens/cart_screen.dart';

import '../features/checkout/screens/checkout_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    GoRoute(
      path: '/login',

      builder: (context, state) =>
          const LoginScreen(),
    ),

    GoRoute(
      path: '/register',

      builder: (context, state) =>
          const RegisterScreen(),
    ),

    GoRoute(
      path: '/home',

      builder: (context, state) =>
          const HomeScreen(),
    ),

    GoRoute(
      path: '/cart',

      builder: (context, state) =>
          const CartScreen(),
    ),

    GoRoute(
      path: '/checkout',

      builder: (context, state) =>
          const CheckoutScreen(),
    ),
  ],
);