import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder:
          (context, state) =>
              const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder:
          (context, state) =>
              const RegisterScreen(),
    ),
  ],
);