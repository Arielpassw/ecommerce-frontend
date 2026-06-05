import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/order_model.dart';
import '../services/orders_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _service = OrdersService();

  bool _isLoading = true;
  String? _error;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _service.getMyOrders();

      if (!mounted) return;

      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;

      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Mis pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Builder(
            builder: (context) {
              if (_isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF8B35FF)),
                );
              }

              if (_error != null) {
                return Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              if (_orders.isEmpty) {
                return const Center(
                  child: Text(
                    'Todavia no tienes pedidos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final shortId = order.id.length > 8
                      ? order.id.substring(0, 8)
                      : order.id;
                  final isPending = order.status.toUpperCase() == 'PENDING';

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (isPending) {
                          context.go('/checkout?orderId=${order.id}');
                          return;
                        }

                        _showOrderInfo(order, shortId);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D101A),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3CFF).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                isPending
                                    ? Icons.payment_outlined
                                    : Icons.shopping_bag_outlined,
                                color: const Color(0xFFB14CFF),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pedido $shortId',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isPending
                                        ? 'Pendiente de pago - tocar para pagar'
                                        : order.status,
                                    style: const TextStyle(color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${order.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFFB14CFF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  isPending
                                      ? Icons.arrow_forward_ios
                                      : Icons.info_outline,
                                  color: Colors.white38,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showOrderInfo(OrderModel order, String shortId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D101A),
        title: Text(
          'Pedido $shortId',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado: ${order.status}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFFB14CFF)),
            ),
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
  }
}
