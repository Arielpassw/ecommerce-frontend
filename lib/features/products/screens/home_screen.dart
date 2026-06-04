import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/products_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    context.go('/login');
  }

  Future<void> addToCart(String productId) async {
    await context.read<CartProvider>().addToCart(productId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF7C3CFF),
        content: Text('Product added to cart'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider =
        context.watch<ProductsProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        return Scaffold(
          backgroundColor: Colors.black,
          drawer: isMobile
              ? _AppDrawer(
                  onLogout: logout,
                  isAdmin: isAdmin,
                  onAdmin: () {
                    context.go('/admin/products');
                  },
                )
              : null,
          appBar: isMobile
              ? AppBar(
                  backgroundColor: Colors.black,
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Ecommerce',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    if (isAdmin)
                      IconButton(
                        tooltip: 'Admin',
                        onPressed: () {
                          context.push('/admin/products');
                        },
                        icon: const Icon(
                          Icons.admin_panel_settings_outlined,
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        context.push('/cart');
                      },
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                      ),
                    ),
                  ],
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                _Sidebar(
                  onLogout: logout,
                  isAdmin: isAdmin,
                  onAdmin: () {
                    context.go('/admin/products');
                  },
                ),
              Expanded(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(
                      isMobile ? 16 : 28,
                    ),
                    child: Builder(
                      builder: (_) {
                        if (productsProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF8B35FF),
                            ),
                          );
                        }

                        if (productsProvider.error != null) {
                          return Center(
                            child: Text(
                              productsProvider.error!,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }

                        final products =
                            productsProvider.products;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (!isMobile)
                                _Header(
                                  searchController:
                                      searchController,
                                  onCart: () {
                                    context.push('/cart');
                                  },
                                  isAdmin: isAdmin,
                                  onAdmin: () {
                                    context.push(
                                      '/admin/products',
                                    );
                                  },
                                ),

                              if (isMobile)
                                _MobileSearch(
                                  controller:
                                      searchController,
                                ),

                              const SizedBox(height: 22),

                              _HeroBanner(
                                isMobile: isMobile,
                              ),

                              const SizedBox(height: 24),

                              const _SectionTitle(
                                title: 'Categories',
                                action: 'Seen all',
                              ),

                              const SizedBox(height: 14),

                              _CategoriesRow(
                                isMobile: isMobile,
                              ),

                              const SizedBox(height: 24),

                              const _SectionTitle(
                                title:
                                    'Featured Products',
                                action: 'Seen all',
                              ),

                              const SizedBox(height: 14),

                              GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      isMobile ? 210 : 230,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio:
                                      isMobile ? 0.70 : 0.72,
                                ),
                                itemBuilder: (context, index) {
                                  final product =
                                      products[index];

                                  return _ProductCard(
                                    name: product.name,
                                    description:
                                        product.description,
                                    price: product.price,
                                    imageUrl:
                                        product.imageUrl,
                                    onAdd: () {
                                      addToCart(product.id);
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              _BenefitsRow(
                                isMobile: isMobile,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final bool isAdmin;
  final VoidCallback onAdmin;

  const _AppDrawer({
    required this.onLogout,
    required this.isAdmin,
    required this.onAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF070811),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFB14CFF),
                    size: 36,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Ecommerce',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const _MenuItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: true,
              ),
              const _MenuItem(
                icon: Icons.category_outlined,
                label: 'Categories',
              ),
              const _MenuItem(
                icon: Icons.favorite_border,
                label: 'Favorites',
              ),
              const _MenuItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Your Orders',
              ),
              if (isAdmin)
                _MenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin',
                  onTap: onAdmin,
                ),
              const _MenuItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
              ),
              const Spacer(),
              _LogoutButton(
                onLogout: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final VoidCallback onLogout;
  final bool isAdmin;
  final VoidCallback onAdmin;

  const _Sidebar({
    required this.onLogout,
    required this.isAdmin,
    required this.onAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF070811),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFFB14CFF),
                size: 38,
              ),
              SizedBox(width: 12),
              Text(
                'Ecommerce',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const _MenuItem(
            icon: Icons.home_outlined,
            label: 'Home',
            active: true,
          ),
          const _MenuItem(
            icon: Icons.category_outlined,
            label: 'Categories',
          ),
          const _MenuItem(
            icon: Icons.favorite_border,
            label: 'Favorites',
          ),
          const _MenuItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Your Orders',
          ),
          if (isAdmin)
            _MenuItem(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Admin',
              onTap: onAdmin,
            ),
          const _MenuItem(
            icon: Icons.local_offer_outlined,
            label: 'Coupons',
          ),
          const _MenuItem(
            icon: Icons.notifications_none,
            label: 'Notifications',
          ),
          const _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
          ),
          const Spacer(),
          _LogoutButton(
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onLogout,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white10,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              SizedBox(width: 12),
              Text(
                'Sign out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [
                      Color(0xFF8B35FF),
                      Color(0xFF5A18D6),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onCart;
  final bool isAdmin;
  final VoidCallback onAdmin;

  const _Header({
    required this.searchController,
    required this.onCart,
    required this.isAdmin,
    required this.onAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hi! ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Discover amazing products and exclusive offers just for you',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 380,
          child: _SearchBox(
            controller: searchController,
          ),
        ),
        const SizedBox(width: 22),
        if (isAdmin) ...[
          _TopIconButton(
            icon: Icons.admin_panel_settings_outlined,
            onTap: onAdmin,
          ),
          const SizedBox(width: 14),
        ],
        _TopIconButton(
          icon: Icons.shopping_cart_outlined,
          badge: '3',
          onTap: onCart,
        ),
        const SizedBox(width: 14),
        const _TopIconButton(
          icon: Icons.notifications_none,
          badge: '2',
        ),
        const SizedBox(width: 18),
        const CircleAvatar(
          backgroundColor: Color(0xFF7C3CFF),
          child: Text(
            'AA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}


class _MobileSearch extends StatelessWidget {
  final TextEditingController controller;

  const _MobileSearch({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _SearchBox(
      controller: controller,
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBox({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        suffixIcon: const Icon(
          Icons.search,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: const Color(0xFF0D101A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF8B35FF),
          ),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback? onTap;

  const _TopIconButton({
    required this.icon,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0D101A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white12,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            if (badge != null)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B35FF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final bool isMobile;

  const _HeroBanner({
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 230 : 300,
      padding: EdgeInsets.all(
        isMobile ? 24 : 44,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white12,
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF10081D),
            Color(0xFF1A0B36),
            Color(0xFF080810),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Text(
                  'SPECIAL OFFER',
                  style: TextStyle(
                    color: Color(0xFFB14CFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 24 : 34,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      const TextSpan(text: 'Until '),
                      TextSpan(
                        text: '30%',
                        style: TextStyle(
                          color: const Color(0xFF8B35FF),
                          fontSize:
                              isMobile ? 34 : 48,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' discount\non selected products',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Seen offers →',
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            const Expanded(
              child: Icon(
                Icons.shopping_bag,
                color: Color(0xFF8B35FF),
                size: 150,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;

  const _SectionTitle({
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '$action →',
          style: const TextStyle(
            color: Color(0xFFB14CFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final bool isMobile;

  const _CategoriesRow({
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      [Icons.grid_view, 'All'],
      [Icons.laptop_mac, 'Electronic'],
      [Icons.headphones, 'Accesories'],
      [Icons.home_outlined, 'Home'],
      [Icons.checkroom, 'Clothes'],
      [Icons.sports_basketball, 'Sports'],
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];

          return Container(
            width: isMobile ? 130 : 150,
            decoration: BoxDecoration(
              color: const Color(0xFF0D101A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: index == 0
                    ? const Color(0xFFB14CFF)
                    : Colors.white12,
              ),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  category[0] as IconData,
                  color: const Color(0xFFB14CFF),
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  category[1] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF121522),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(
                          Icons.image,
                          color: Colors.white30,
                          size: 60,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.image,
                      color: Colors.white30,
                      size: 60,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFB14CFF),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(
                      Icons.shopping_cart,
                    ),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF7C3CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsRow extends StatelessWidget {
  final bool isMobile;

  const _BenefitsRow({
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final benefits = const [
      _BenefitCard(
        icon: Icons.local_shipping,
        title: 'Shopping fast',
        subtitle: 'Receive your products in 24-48 hours',
      ),
      _BenefitCard(
        icon: Icons.verified_user,
        title: 'Secure Payments',
        subtitle: 'Your payments are 100% protected',
      ),
      _BenefitCard(
        icon: Icons.refresh,
        title: 'Returns',
        subtitle: '30 days for returns',
      ),
      _BenefitCard(
        icon: Icons.headset_mic,
        title: '24/7 Support ',
        subtitle: 'We are here to help',
      ),
    ];

    if (isMobile) {
      return Column(
        children: benefits
            .map(
              (item) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 12),
                child: item,
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: benefits
          .map(
            (item) => Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(right: 14),
                child: item,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB14CFF),
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
