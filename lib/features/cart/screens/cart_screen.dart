import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState
    extends State<CartScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider =
        context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount:
                  cartProvider.items.length,

              itemBuilder: (
                context,
                index,
              ) {
                final item =
                    cartProvider.items[index];

                return ListTile(
                  leading:
                      item.product.imageUrl !=
                              null
                          ? Image.network(
                              item.product.imageUrl!,
                              width: 50,
                            )
                          : const Icon(
                              Icons.image,
                            ),

                  title: Text(
                    item.product.name,
                  ),

                  subtitle: Text(
                    'Cantidad: ${item.quantity}',
                  ),

                  trailing: IconButton(
                    onPressed: () {
                      cartProvider.removeItem(
                        item.id,
                      );
                    },

                    icon: const Icon(
                      Icons.delete,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              children: [
                Text(
                  'Total: \$${cartProvider.total.toStringAsFixed(2)}',

                  style: const TextStyle(
                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        '/checkout',
                      );
                    },

                    child: const Text(
                      'Checkout',
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