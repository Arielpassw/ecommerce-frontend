import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../orders/models/order_model.dart';
import '../../orders/services/orders_service.dart';
import '../../payments/services/payments_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrdersService ordersService = OrdersService();
  final PaymentsService paymentsService = PaymentsService();

  bool isLoading = false;
  OrderModel? order;

  Future<void> createOrder() async {
    setState(() {
      isLoading = true;
    });

    try {
      final createdOrder = await ordersService.checkout();

      setState(() {
        order = createdOrder;
      });
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> payWithStripe() async {
    if (order == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = await paymentsService.createStripeSession(
        orderId: order!.id,
        amount: order!.totalAmount,
      );

      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> payWithPaypal() async {
    if (order == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await paymentsService.createPaypalOrder(
        orderId: order!.id,
        amount: order!.totalAmount,
      );

      final paypalOrderId = response['paypalOrderId'];
      final approveLink = response['approveLink'];

      await launchUrl(
        Uri.parse(approveLink),
        mode: LaunchMode.externalApplication,
      );

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Pago PayPal'),
            content: const Text(
              'Después de aprobar el pago en PayPal, regresa aquí y presiona Confirmar pago.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await paymentsService.capturePaypalOrder(
                    paypalOrderId: paypalOrderId,
                    orderId: order!.id,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pago PayPal confirmado'),
                    ),
                  );
                },
                child: const Text('Confirmar pago'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    createOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Checkout')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : order == null
                ? const Text('No se pudo crear la orden')
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Orden creada',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text('ID: ${order!.id}'),
                        const SizedBox(height: 12),
                        Text(
                          'Total: \$${order!.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: payWithStripe,
                            child: const Text(
                              'Pagar con Stripe',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: payWithPaypal,
                            child: const Text(
                              'Pagar con PayPal',
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