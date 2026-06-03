import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    createOrder();
  }

  Future<void> createOrder() async {
    setState(() {
      isLoading = true;
    });

    try {
      final createdOrder =
          await ordersService.checkout();

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
      final url =
          await paymentsService.createStripeSession(
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
      final response =
          await paymentsService.createPaypalOrder(
        orderId: order!.id,
        amount: order!.totalAmount,
      );

      final paypalOrderId = response['paypalOrderId'];
      final approveLink = response['approveLink'];

      await launchUrl(
        Uri.parse(approveLink),
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D101A),
            title: const Text(
              'Pago PayPal',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'After approving the payments payment on PayPal, return here and press Confirm Patment.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await paymentsService.capturePaypalOrder(
                    paypalOrderId: paypalOrderId,
                    orderId: order!.id,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF7C3CFF),
                      content: Text(
                        'PayPal payment confirmed',
                      ),
                    ),
                  );
                },
                child: const Text('Confirmed payment'),
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
        backgroundColor: Colors.redAccent,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundGlow(),

            Column(
              children: [
                _CheckoutHeader(
                  onBack: () {
                    context.pop();
                  },
                ),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                            color: Color(0xFF8B35FF),
                          ),
                        )
                      : order == null
                          ? const Center(
                              child: Text(
                                'The order could not be created',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.all(24),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(
                                    maxWidth: 520,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      _OrderCard(
                                        order: order!,
                                      ),

                                      const SizedBox(
                                          height: 28),

                                      const Text(
                                        'Select a payment method',
                                        style: TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize: 24,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 18),

                                      _PaymentOption(
                                        title:
                                            'Pay with Stripe',
                                        subtitle:
                                            'Pay securely with your credit or debit card',
                                        iconText: 'S',
                                        gradient:
                                            const LinearGradient(
                                          colors: [
                                            Color(
                                                0xFF6C63FF),
                                            Color(
                                                0xFF8B35FF),
                                          ],
                                        ),
                                        onTap:
                                            payWithStripe,
                                      ),

                                      const SizedBox(
                                          height: 16),

                                      _PaymentOption(
                                        title:
                                            'Pay with PayPal',
                                        subtitle:
                                            'Pay securely with your PayPal account',
                                        iconText: 'P',
                                        gradient:
                                            const LinearGradient(
                                          colors: [
                                            Color(
                                                0xFFffffff),
                                            Color(
                                                0xFFEFEFFF),
                                          ],
                                        ),
                                        iconColor:
                                            const Color(
                                                0xFF0070BA),
                                        onTap:
                                            payWithPaypal,
                                      ),

                                      const SizedBox(
                                          height: 24),

                                      const _SecurePaymentCard(),
                                    ],
                                  ),
                                ),
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

class _CheckoutHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _CheckoutHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
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
                'Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF7C3CFF).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3CFF)
                .withOpacity(0.18),
            blurRadius: 35,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8B35FF),
                width: 5,
              ),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 48,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '¡Created Order!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your order has been successfully created',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 26),

          const Divider(color: Colors.white12),

          const SizedBox(height: 18),

          _OrderInfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'Order ID',
            value: order.id,
          ),

          const SizedBox(height: 22),

          const Divider(color: Colors.white12),

          const SizedBox(height: 18),

          _OrderInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total to pay',
            value:
                '\$${order.totalAmount.toStringAsFixed(2)}',
            large: true,
          ),
        ],
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool large;

  const _OrderInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFB14CFF),
          size: 48,
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: large ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: large ? 38 : 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconText;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.iconText,
    required this.gradient,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D101A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF8B35FF)
                  .withOpacity(0.75),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                ),
                child: Center(
                  child: Text(
                    iconText,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 22),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFB14CFF),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurePaymentCard extends StatelessWidget {
  const _SecurePaymentCard();

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
            size: 62,
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '100% secure payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your data and payments are protected with bank-level encrytion.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
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

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -140,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  const Color(0xFF7C3CFF).withOpacity(0.18),
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
              color:
                  const Color(0xFFB14CFF).withOpacity(0.10),
            ),
          ),
        ),
      ],
    );
  }
}