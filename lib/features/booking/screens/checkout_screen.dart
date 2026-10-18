import 'package:flutter/material.dart';

/// Pantalla esqueleto de Checkout y Pago Seguro (Planificada para Sprint 2 • CU-06).
///
/// Mantiene la estructura modular del proyecto sin adelantar funcionalidad fuera del Sprint 1.
class CheckoutScreen extends StatelessWidget {
  /// Identificador de la experiencia a reservar.
  final int experienceId;

  /// Crea una instancia de [CheckoutScreen].
  const CheckoutScreen({super.key, required this.experienceId});

  /// Firma de acción para iniciar el flujo de pago con Stripe en Sprint 2.
  void onPayWithStripePressed() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Text('Checkout for Experience #$experienceId (Sprint 2)'),
      ),
    );
  }
}
