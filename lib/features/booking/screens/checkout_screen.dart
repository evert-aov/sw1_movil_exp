import 'package:flutter/material.dart';

// Pantalla esqueleto de Checkout y Pago Seguro (CU-05, CU-06)
class CheckoutScreen extends StatelessWidget {
  final int experienceId;

  const CheckoutScreen({super.key, required this.experienceId});

  void onPayWithStripePressed() {
    // Firma de acción para redireccionar al flujo de pago seguro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Text('Checkout for Experience #$experienceId'),
      ),
    );
  }
}
