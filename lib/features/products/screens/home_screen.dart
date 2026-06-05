import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/services/profile_service.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';
import '../providers/products_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _categoriesKey = GlobalKey();
  final _profileService = ProfileService();
  bool _showOffersOnly = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProductsProvider>().loadProducts();
      context.read<CartProvider>().loadCart();
    });

    _searchController.addListener(() {
      context.read<ProductsProvider>().updateSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    context.go('/login');
  }

  Future<void> _addToCart(String productId) async {
    await context.read<CartProvider>().addToCart(productId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF7C3CFF),
        content: Text('Producto agregado al carrito'),
      ),
    );
  }

  void _goHome() {
    setState(() => _showOffersOnly = false);
    context.read<ProductsProvider>().selectCategory(null);
    _scrollTop();
  }

  void _goCategories() {
    setState(() => _showOffersOnly = false);
    final target = _categoriesKey.currentContext;

    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showOffers() {
    setState(() => _showOffersOnly = true);
    _scrollTop();
  }

  void _showInfo(String title, String message, IconData icon) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D101A),
        title: Row(
          children: [
            Icon(icon, color: const Color(0xFFB14CFF)),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFFB14CFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartNotification(int cartCount) {
    if (cartCount > 0) {
      _showInfo(
        'Notificaciones',
        'Tienes $cartCount producto${cartCount == 1 ? '' : 's'} en el carrito. Termina tu compra antes de que se agoten.',
        Icons.notifications_none,
      );
      return;
    }

    _showInfo(
      'Notificaciones',
      'No tienes productos pendientes en el carrito.',
      Icons.notifications_none,
    );
  }

  Future<void> _showProfile() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B35FF)),
      ),
    );

    try {
      final profile = await _profileService.getProfile();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0D101A),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF7C3CFF),
                child: Text(
                  profile.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Perfil',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileLine(label: 'Nombre', value: profile.fullName),
              _ProfileLine(label: 'Email', value: profile.email),
              _ProfileLine(label: 'Rol', value: profile.role),
              if (profile.phone != null && profile.phone!.isNotEmpty)
                _ProfileLine(label: 'Telefono', value: profile.phone!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Color(0xFFB14CFF)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      _showInfo(
        'Perfil',
        'No se pudo cargar la informacion del perfil.',
        Icons.person_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final cartCount = context.watch<CartProvider>().items.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;
        final products = _showOffersOnly
            ? productsProvider.visibleProducts
                .where(
                  (product) =>
                      product.discount != null && product.discount! > 0,
                )
                .toList()
            : productsProvider.visibleProducts;

        return Scaffold(
          backgroundColor: Colors.black,
          drawer: isMobile
              ? _AppDrawer(
                  isAdmin: isAdmin,
                  notificationCount: cartCount,
                  onHome: _goHome,
                  onCategories: _goCategories,
                  onOrders: () => context.go('/orders'),
                  onAdmin: () => context.go('/admin/products'),
                  onCoupons: () => _showInfo(
                    'Cupones',
                    'Aun no tienes cupones disponibles.',
                    Icons.local_offer_outlined,
                  ),
                  onNotifications: () => _showCartNotification(cartCount),
                  onSettings: () => _showInfo(
                    'Configuracion',
                    'Tu sesion esta activa. Puedes cerrar sesion desde el menu.',
                    Icons.settings_outlined,
                  ),
                  onLogout: _logout,
                )
              : null,
          appBar: isMobile
              ? AppBar(
                  backgroundColor: Colors.black,
                  iconTheme: const IconThemeData(color: Colors.white),
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
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        onPressed: () => context.go('/admin/products'),
                      ),
                    IconButton(
                      tooltip: 'Carrito',
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () => context.go('/cart'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: _showProfile,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF7C3CFF),
                          child: Text(
                            'AA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                _Sidebar(
                  isAdmin: isAdmin,
                  notificationCount: cartCount,
                  onHome: _goHome,
                  onCategories: _goCategories,
                  onOrders: () => context.go('/orders'),
                  onAdmin: () => context.go('/admin/products'),
                  onCoupons: () => _showInfo(
                    'Cupones',
                    'Aun no tienes cupones disponibles.',
                    Icons.local_offer_outlined,
                  ),
                  onNotifications: () => _showCartNotification(cartCount),
                  onSettings: () => _showInfo(
                    'Configuracion',
                    'Tu sesion esta activa. Puedes cerrar sesion desde el menu.',
                    Icons.settings_outlined,
                  ),
                  onLogout: _logout,
                ),
              Expanded(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 28),
                    child: _HomeContent(
                      isMobile: isMobile,
                      isLoading: productsProvider.isLoading,
                      error: productsProvider.error,
                      products: products,
                      categories: productsProvider.categories,
                      selectedCategoryId: productsProvider.selectedCategoryId,
                      showOffersOnly: _showOffersOnly,
                      searchController: _searchController,
                      scrollController: _scrollController,
                      categoriesKey: _categoriesKey,
                      cartCount: cartCount,
                      isAdmin: isAdmin,
                      onCart: () => context.go('/cart'),
                      onAdmin: () => context.go('/admin/products'),
                      onNotifications: () => _showCartNotification(cartCount),
                      onProfile: _showProfile,
                      onShowOffers: _showOffers,
                      onSelectCategory: (categoryId) {
                        setState(() => _showOffersOnly = false);
                        context.read<ProductsProvider>().selectCategory(
                              categoryId,
                            );
                      },
                      onShowAll: _goHome,
                      onAddToCart: _addToCart,
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

class _HomeContent extends StatelessWidget {
  final bool isMobile;
  final bool isLoading;
  final String? error;
  final List<ProductModel> products;
  final List<ProductCategoryModel> categories;
  final String? selectedCategoryId;
  final bool showOffersOnly;
  final TextEditingController searchController;
  final ScrollController scrollController;
  final GlobalKey categoriesKey;
  final int cartCount;
  final bool isAdmin;
  final VoidCallback onCart;
  final VoidCallback onAdmin;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onShowOffers;
  final ValueChanged<String?> onSelectCategory;
  final VoidCallback onShowAll;
  final ValueChanged<String> onAddToCart;

  const _HomeContent({
    required this.isMobile,
    required this.isLoading,
    required this.error,
    required this.products,
    required this.categories,
    required this.selectedCategoryId,
    required this.showOffersOnly,
    required this.searchController,
    required this.scrollController,
    required this.categoriesKey,
    required this.cartCount,
    required this.isAdmin,
    required this.onCart,
    required this.onAdmin,
    required this.onNotifications,
    required this.onProfile,
    required this.onShowOffers,
    required this.onSelectCategory,
    required this.onShowAll,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B35FF)),
      );
    }

    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.white)),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            _Header(
              searchController: searchController,
              cartCount: cartCount,
              isAdmin: isAdmin,
              onCart: onCart,
              onAdmin: onAdmin,
              onNotifications: onNotifications,
              onProfile: onProfile,
            ),
          if (isMobile) _SearchBox(controller: searchController),
          const SizedBox(height: 22),
          _HeroBanner(isMobile: isMobile, onSeeOffers: onShowOffers),
          const SizedBox(height: 24),
          _SectionTitle(
            key: categoriesKey,
            title: 'Categories',
            action: 'See all',
            onAction: () => onSelectCategory(null),
          ),
          const SizedBox(height: 14),
          _CategoriesRow(
            isMobile: isMobile,
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onSelected: onSelectCategory,
          ),
          const SizedBox(height: 24),
          _SectionTitle(
            title: showOffersOnly ? 'Products on Offer' : 'Featured Products',
            action: showOffersOnly ? 'Show all' : 'See all',
            onAction: onShowAll,
          ),
          const SizedBox(height: 14),
          if (products.isEmpty)
            _EmptyProductsMessage(isOffers: showOffersOnly)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isMobile ? 210 : 230,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isMobile ? 0.70 : 0.72,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return _ProductCard(
                  name: product.name,
                  price: product.price,
                  discount: product.discount,
                  imageUrl: product.imageUrl,
                  onAdd: () => onAddToCart(product.id),
                );
              },
            ),
          const SizedBox(height: 24),
          _BenefitsRow(isMobile: isMobile),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final bool isAdmin;
  final int notificationCount;
  final VoidCallback onHome;
  final VoidCallback onCategories;
  final VoidCallback onOrders;
  final VoidCallback onAdmin;
  final VoidCallback onCoupons;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _AppDrawer({
    required this.isAdmin,
    required this.notificationCount,
    required this.onHome,
    required this.onCategories,
    required this.onOrders,
    required this.onAdmin,
    required this.onCoupons,
    required this.onNotifications,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF070811),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _MenuContent(
            isAdmin: isAdmin,
            notificationCount: notificationCount,
            onHome: onHome,
            onCategories: onCategories,
            onOrders: onOrders,
            onAdmin: onAdmin,
            onCoupons: onCoupons,
            onNotifications: onNotifications,
            onSettings: onSettings,
            onLogout: onLogout,
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final bool isAdmin;
  final int notificationCount;
  final VoidCallback onHome;
  final VoidCallback onCategories;
  final VoidCallback onOrders;
  final VoidCallback onAdmin;
  final VoidCallback onCoupons;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.isAdmin,
    required this.notificationCount,
    required this.onHome,
    required this.onCategories,
    required this.onOrders,
    required this.onAdmin,
    required this.onCoupons,
    required this.onNotifications,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF070811),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: _MenuContent(
        isAdmin: isAdmin,
        notificationCount: notificationCount,
        onHome: onHome,
        onCategories: onCategories,
        onOrders: onOrders,
        onAdmin: onAdmin,
        onCoupons: onCoupons,
        onNotifications: onNotifications,
        onSettings: onSettings,
        onLogout: onLogout,
      ),
    );
  }
}

class _MenuContent extends StatelessWidget {
  final bool isAdmin;
  final int notificationCount;
  final VoidCallback onHome;
  final VoidCallback onCategories;
  final VoidCallback onOrders;
  final VoidCallback onAdmin;
  final VoidCallback onCoupons;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _MenuContent({
    required this.isAdmin,
    required this.notificationCount,
    required this.onHome,
    required this.onCategories,
    required this.onOrders,
    required this.onAdmin,
    required this.onCoupons,
    required this.onNotifications,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 34),
        Expanded(
          child: ListView(
            children: [
              _MenuItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: true,
                onTap: onHome,
              ),
              _MenuItem(
                icon: Icons.category_outlined,
                label: 'Categories',
                onTap: onCategories,
              ),
              _MenuItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Your Orders',
                onTap: onOrders,
              ),
              if (isAdmin)
                _MenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin',
                  onTap: onAdmin,
                ),
              _MenuItem(
                icon: Icons.local_offer_outlined,
                label: 'Coupons',
                onTap: onCoupons,
              ),
              _MenuItem(
                icon: Icons.notifications_none,
                label: 'Notifications',
                badge: notificationCount == 0 ? null : '$notificationCount',
                onTap: onNotifications,
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: onSettings,
              ),
            ],
          ),
        ),
        _LogoutButton(onLogout: onLogout),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF8B35FF), Color(0xFF5A18D6)],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B35FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

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
            border: Border.all(color: Colors.white10),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sign out',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
  final int cartCount;
  final bool isAdmin;
  final VoidCallback onCart;
  final VoidCallback onAdmin;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _Header({
    required this.searchController,
    required this.cartCount,
    required this.isAdmin,
    required this.onCart,
    required this.onAdmin,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Discover amazing products and exclusive offers just for you',
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ],
          ),
        ),
        SizedBox(width: 380, child: _SearchBox(controller: searchController)),
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
          badge: cartCount == 0 ? null : '$cartCount',
          onTap: onCart,
        ),
        const SizedBox(width: 14),
        _TopIconButton(
          icon: Icons.notifications_none,
          badge: cartCount == 0 ? null : '$cartCount',
          onTap: onNotifications,
        ),
        const SizedBox(width: 18),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onProfile,
            child: const CircleAvatar(
              backgroundColor: Color(0xFF7C3CFF),
              child: Text(
                'AA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileLine extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: const TextStyle(color: Colors.white38),
        suffixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF0D101A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF8B35FF)),
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
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
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
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(icon, color: Colors.white),
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
  final VoidCallback onSeeOffers;

  const _HeroBanner({
    required this.isMobile,
    required this.onSeeOffers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 230 : 300,
      padding: EdgeInsets.all(isMobile ? 24 : 44),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
        gradient: const LinearGradient(
          colors: [Color(0xFF10081D), Color(0xFF1A0B36), Color(0xFF080810)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                          fontSize: isMobile ? 34 : 48,
                        ),
                      ),
                      const TextSpan(text: ' discount\non selected products'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onSeeOffers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('See offers ->'),
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
  final VoidCallback? onAction;

  const _SectionTitle({
    super.key,
    required this.title,
    required this.action,
    this.onAction,
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
        MouseRegion(
          cursor: onAction == null ? MouseCursor.defer : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onAction,
            child: Text(
              '$action ->',
              style: const TextStyle(
                color: Color(0xFFB14CFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final bool isMobile;
  final List<ProductCategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  const _CategoriesRow({
    required this.isMobile,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final categoryId = category?.id;
          final label = isAll ? 'All' : category!.name;
          final isSelected = isAll
              ? selectedCategoryId == null
              : selectedCategoryId == categoryId;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(categoryId),
              child: Container(
                width: isMobile ? 130 : 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D101A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFB14CFF)
                        : Colors.white12,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _categoryIcon(label),
                      color: const Color(0xFFB14CFF),
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        },
      ),
    );
  }

  IconData _categoryIcon(String name) {
    final normalized = name.toLowerCase();

    if (normalized.contains('laptop')) return Icons.laptop_mac;
    if (normalized.contains('smart')) return Icons.smartphone;
    if (normalized.contains('monitor')) return Icons.monitor;
    if (normalized.contains('audio')) return Icons.headphones;
    if (normalized.contains('gaming')) return Icons.sports_esports;
    if (normalized.contains('perifer')) return Icons.keyboard_alt_outlined;

    return Icons.grid_view;
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final double? discount;
  final String? imageUrl;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.discount,
    required this.imageUrl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF121522),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image,
                          color: Colors.white30,
                          size: 60,
                        ),
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.white30, size: 60),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (discount != null && discount! > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${discount!.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Color(0xFFB14CFF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

class _EmptyProductsMessage extends StatelessWidget {
  final bool isOffers;

  const _EmptyProductsMessage({
    this.isOffers = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(
            isOffers ? Icons.local_offer_outlined : Icons.inventory_2_outlined,
            color: const Color(0xFFB14CFF),
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            isOffers
                ? 'No hay ofertas disponibles por ahora'
                : 'No hay productos para mostrar',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsRow extends StatelessWidget {
  final bool isMobile;

  const _BenefitsRow({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final benefits = const [
      _BenefitCard(
        icon: Icons.local_shipping,
        title: 'Fast shipping',
        subtitle: 'Receive your products in 24-48 hours',
      ),
      _BenefitCard(
        icon: Icons.verified_user,
        title: 'Secure Payments',
        subtitle: 'Your payments are protected',
      ),
      _BenefitCard(
        icon: Icons.refresh,
        title: 'Returns',
        subtitle: '30 days for returns',
      ),
      _BenefitCard(
        icon: Icons.headset_mic,
        title: '24/7 Support',
        subtitle: 'We are here to help',
      ),
    ];

    if (isMobile) {
      return Column(
        children: benefits
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                padding: const EdgeInsets.only(right: 14),
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
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB14CFF), size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
