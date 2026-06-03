import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      await context.read<AuthProvider>().login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                const _BackgroundGlow(),

                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 22 : 28,
                      vertical: isMobile ? 26 : 34,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? 420 : 460,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: isMobile ? 10 : 20,
                          ),

                          Text(
                            'Ecommerce',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 38 : 46,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          SizedBox(
                            height: isMobile ? 24 : 30,
                          ),

                          Container(
                            height: isMobile ? 125 : 150,
                            width: isMobile ? 125 : 150,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF151515),
                              borderRadius:
                                  BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C3CFF,
                                  ).withOpacity(0.35),
                                  blurRadius: 35,
                                  spreadRadius: 3,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white12,
                              ),
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color:
                                  const Color(0xFFB14CFF),
                              size: isMobile ? 66 : 80,
                            ),
                          ),

                          SizedBox(
                            height: isMobile ? 28 : 32,
                          ),

                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 30 : 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Sign in to continue shopping',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(
                            height: isMobile ? 30 : 36,
                          ),

                          _DarkInput(
                            controller: emailController,
                            hintText: 'Email or username',
                            icon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 18),

                          _DarkInput(
                            controller:
                                passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment:
                                Alignment.centerRight,
                            child: MouseRegion(
                              cursor:
                                  SystemMouseCursors.click,
                              child: TextButton(
                                onPressed: () {
                                  // Próximo módulo:
                                  // context.push('/forgot-password');
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color:
                                        Color(0xFFB14CFF),
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          MouseRegion(
                            cursor: authProvider.isLoading
                                ? SystemMouseCursors.basic
                                : SystemMouseCursors.click,
                            child: SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed:
                                    authProvider.isLoading
                                        ? null
                                        : login,
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                      Colors.white,
                                  foregroundColor:
                                      Colors.black,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(16),
                                  ),
                                ),
                                child: authProvider
                                        .isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account? ",
                                style: TextStyle(
                                  color: Colors.white60,
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors
                                    .click,
                                child: GestureDetector(
                                  onTap: () {
                                    context.push(
                                      '/register',
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color:
                                          Color(0xFFB14CFF),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: const [
                              Expanded(
                                child: Divider(
                                  color: Colors.white24,
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white24,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: const [
                              _SocialButton(
                                icon: Icons.facebook,
                              ),
                              _SocialButton(
                                icon: Icons
                                    .camera_alt_outlined,
                              ),
                              _SocialButton(
                                icon: Icons.apple,
                              ),
                              _SocialButton(
                                icon: Icons.alternate_email,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DarkInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _DarkInput({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFB14CFF),
        ),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white54,
        ),
        filled: true,
        fillColor: const Color(0xFF0D101A),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: const Color(0xFF7C3CFF)
                .withOpacity(0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFB14CFF),
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;

  const _SocialButton({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3CFF)
                  .withOpacity(0.18),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -130,
          left: -100,
          child: Container(
            width: 330,
            height: 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3CFF)
                  .withOpacity(0.16),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -120,
          child: Container(
            width: 390,
            height: 390,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB14CFF)
                  .withOpacity(0.10),
            ),
          ),
        ),
      ],
    );
  }
}