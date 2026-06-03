import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final firstNameController =
      TextEditingController();
  final lastNameController =
      TextEditingController();
  final emailController =
      TextEditingController();
  final passwordController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    try {
      await context.read<AuthProvider>().register(
            firstName:
                firstNameController.text.trim(),
            lastName:
                lastNameController.text.trim(),
            email: emailController.text.trim(),
            password:
                passwordController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF7C3CFF),
          content: Text(
            'Successfully registered user',
          ),
        ),
      );

      context.go('/login');
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
        final isMobile = constraints.maxWidth < 760;

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                const _BackgroundGlow(),

                Positioned(
                  top: 18,
                  left: 18,
                  child: MouseRegion(
                    cursor:
                        SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF171020),
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white12,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal:
                          isMobile ? 20 : 28,
                      vertical:
                          isMobile ? 84 : 32,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            isMobile ? 440 : 1180,
                      ),
                      child: isMobile
                          ? _MobileRegisterContent(
                              firstNameController:
                                  firstNameController,
                              lastNameController:
                                  lastNameController,
                              emailController:
                                  emailController,
                              passwordController:
                                  passwordController,
                              obscurePassword:
                                  obscurePassword,
                              onTogglePassword: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                              onRegister:
                                  authProvider.isLoading
                                      ? null
                                      : register,
                              isLoading:
                                  authProvider.isLoading,
                            )
                          : Row(
                              children: [
                                const Expanded(
                                  child:
                                      _PromoPanel(),
                                ),
                                const SizedBox(
                                    width: 40),
                                Expanded(
                                  child:
                                      _RegisterPanel(
                                    firstNameController:
                                        firstNameController,
                                    lastNameController:
                                        lastNameController,
                                    emailController:
                                        emailController,
                                    passwordController:
                                        passwordController,
                                    obscurePassword:
                                        obscurePassword,
                                    onTogglePassword:
                                        () {
                                      setState(() {
                                        obscurePassword =
                                            !obscurePassword;
                                      });
                                    },
                                    onRegister:
                                        authProvider
                                                .isLoading
                                            ? null
                                            : register,
                                    isLoading:
                                        authProvider
                                            .isLoading,
                                  ),
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

class _MobileRegisterContent extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback? onRegister;
  final bool isLoading;

  const _MobileRegisterContent({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.shopping_bag_outlined,
          color: Color(0xFFB14CFF),
          size: 72,
        ),
        const SizedBox(height: 18),
        const Text(
          'Create account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Register and start shopping',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),

        _RegisterPanel(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
          emailController: emailController,
          passwordController: passwordController,
          obscurePassword: obscurePassword,
          onTogglePassword: onTogglePassword,
          onRegister: onRegister,
          isLoading: isLoading,
          compact: true,
        ),
      ],
    );
  }
}

class _PromoPanel extends StatelessWidget {
  const _PromoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 620,
      ),
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF080611),
            Color(0xFF130A2B),
            Color(0xFF07070B),
          ],
        ),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27FF)
                          .withOpacity(0.35),
                      blurRadius: 80,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.shopping_bag,
                size: 210,
                color: Color(0xFF8B35FF),
              ),
              const Positioned(
                top: 50,
                left: 50,
                child: _FloatingIcon(
                  icon: Icons.percent,
                ),
              ),
              const Positioned(
                right: 45,
                top: 65,
                child: _FloatingIcon(
                  icon: Icons.favorite_border,
                ),
              ),
              const Positioned(
                right: 55,
                bottom: 70,
                child: _FloatingIcon(
                  icon: Icons.card_giftcard,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Create your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'and start shopping',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB14CFF),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Join and discover amazing products,\nexclusive offers and a unique experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 34),

          const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              _FeatureCard(
                icon: Icons.local_shipping,
                title: 'Shopping',
                subtitle: 'Fast',
              ),
              SizedBox(width: 18),
              _FeatureCard(
                icon: Icons.verified_user,
                title: 'Secure',
                subtitle: 'Payments',
              ),
              SizedBox(width: 18),
              _FeatureCard(
                icon: Icons.workspace_premium,
                title: 'Quality',
                subtitle: 'Guaranteed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterPanel extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback? onRegister;
  final bool isLoading;
  final bool compact;

  const _RegisterPanel({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onRegister,
    required this.isLoading,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: compact ? 0 : 620,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 24 : 42,
        vertical: compact ? 26 : 34,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF0B0D14).withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF7C3CFF)
              .withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3CFF)
                .withOpacity(0.15),
            blurRadius: 35,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            compact
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          if (!compact) ...[
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3CFF)
                    .withOpacity(0.16),
                border: Border.all(
                  color: const Color(0xFF9B4DFF),
                ),
              ),
              child: const Icon(
                Icons.group_outlined,
                color: Color(0xFFB14CFF),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Complete your information to register',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),
          ],

          if (compact)
            Column(
              children: [
                _DarkField(
                  controller: firstNameController,
                  hintText: 'Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _DarkField(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  icon: Icons.person_outline,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _DarkField(
                    controller: firstNameController,
                    hintText: 'Name',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DarkField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          _DarkField(
            controller: emailController,
            hintText: 'Email',
            icon: Icons.email_outlined,
          ),

          const SizedBox(height: 16),

          _DarkField(
            controller: passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
            ),
          ),

          const SizedBox(height: 28),

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF8B35FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_alt),
                          SizedBox(width: 12),
                          Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 28),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          Row(
            children: const [
              Expanded(
                child: Divider(
                  color: Colors.white24,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Text(
                  'or register with',
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

          const SizedBox(height: 20),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: const [
              _SocialChip(
                label: 'Google',
                icon: Icons.g_mobiledata,
              ),
              _SocialChip(
                label: 'Facebook',
                icon: Icons.facebook,
              ),
              _SocialChip(
                label: 'Apple',
                icon: Icons.apple,
              ),
              _SocialChip(
                label: 'Email',
                icon: Icons.alternate_email,
              ),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: const Text(
                    'Sign in →',
                    style: TextStyle(
                      color: Color(0xFFB14CFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _DarkField({
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
        fillColor: const Color(0xFF11131C),
        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 21,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF7C3CFF)
                .withOpacity(0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFB14CFF),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;

  const _FloatingIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF1A102B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white12,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB14CFF)
                .withOpacity(0.35),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFFDF65FF),
        size: 30,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFB14CFF),
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SocialChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
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
          top: -150,
          left: -100,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3CFF)
                  .withOpacity(0.18),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -80,
          child: Container(
            width: 420,
            height: 420,
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