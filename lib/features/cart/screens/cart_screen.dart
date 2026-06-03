import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundGlow(),

            Column(
              children: [
                _CartHeader(
                  itemCount: cartProvider.items.length,
                  onBack: () {
                    context.pop();
                  },
                ),

                Expanded(
                  child: cartProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B35FF),
                          ),
                        )
                      : cartProvider.items.isEmpty
                          ? const Center(
                              child: Text(
                                'Tu carrito está vacío',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _CartResumeCard(
                                    itemCount:
                                        cartProvider.items.length,
                                  ),

                                  const SizedBox(height: 20),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D101A),
                                      borderRadius:
                                          BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white12,
                                      ),
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          cartProvider.items.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(
                                        color: Colors.white12,
                                        height: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        final item =
                                            cartProvider.items[index];

                                        return _CartItemCard(
                                          imageUrl:
                                              item.product.imageUrl,
                                          name: item.product.name,
                                          price: item.product.price,
                                          quantity: item.quantity,
                                          onDelete: () {
                                            cartProvider.removeItem(
                                              item.id,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  const _SecureCard(),

                                  const SizedBox(height: 20),

                                  _CheckoutSummary(
                                    total: cartProvider.total,
                                    onCheckout: () {
                                      context.push('/checkout');
                                    },
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  final int itemCount;
  final VoidCallback onBack;

  const _CartHeader({
    required this.itemCount,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Carrito',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 38,
              ),
              Positioned(
                top: -12,
                right: -12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B35FF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    itemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

class _CartResumeCard extends StatelessWidget {
  final int itemCount;

  const _CartResumeCard({
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFF31106B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 42,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'You have $itemCount products in your cart',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Review the products and continue with your purchase',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
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

class _CartItemCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double price;
  final int quantity;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.quantity,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              color: const Color(0xFF121522),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white12,
              ),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(
                        Icons.image,
                        color: Colors.white30,
                        size: 50,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image,
                    color: Colors.white30,
                    size: 50,
                  ),
          ),

          const SizedBox(width: 18),

          Expanded(
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFB14CFF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: 130,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF11131C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(
                        Icons.remove,
                        color: Color(0xFFB14CFF),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.add,
                        color: Color(0xFFB14CFF),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.35),
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecureCard extends StatelessWidget {
  const _SecureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.security,
            color: Color(0xFF8B35FF),
            size: 54,
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Compra segura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tus datos y pagos están protegidos con cifrado de nivel bancario.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                    height: 1.4,
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

class _CheckoutSummary extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  const _CheckoutSummary({
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB14CFF),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile =
              constraints.maxWidth < 500;

          if (isMobile) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                _CheckoutButton(
                  onCheckout: onCheckout,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total a pagar',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 230,
                child: _CheckoutButton(
                  onCheckout: onCheckout,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final VoidCallback onCheckout;

  const _CheckoutButton({
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: onCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3CFF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 14),
              Icon(
                Icons.arrow_forward,
                size: 28,
              ),
            ],
          ),
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
          top: -140,
          left: -120,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3CFF)
                  .withOpacity(0.16),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -120,
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