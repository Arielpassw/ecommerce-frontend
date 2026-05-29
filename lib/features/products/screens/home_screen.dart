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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  Future<void> logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider =
        context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/cart');
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (productsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (productsProvider.error != null) {
            return Center(
              child: Text(productsProvider.error!),
            );
          }

          if (productsProvider.products.isEmpty) {
            return const Center(
              child: Text('No hay productos'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemCount:
                productsProvider.products.length,
            itemBuilder: (context, index) {
              final product =
                  productsProvider.products[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(
                                  Icons.image,
                                  size: 60,
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                size: 60,
                              ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await context
                                    .read<CartProvider>()
                                    .addToCart(
                                      product.id,
                                    );

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Producto agregado',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Agregar',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}