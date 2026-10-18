import 'package:flutter/material.dart';

/// Pantalla esqueleto de Mis Entradas y Códigos QR (Planificada para Sprint 2 • HU-12).
///
/// Conserva la firma arquitectónica para la billetera de pases digitales del asistente.
class MyTicketsScreen extends StatelessWidget {
  /// Crea una instancia de [MyTicketsScreen].
  const MyTicketsScreen({super.key});

  /// Firma de acción para desplegar el código QR de ingreso en puerta.
  void onScanQrForEntry(String ticketCode) {}

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('My Tickets & QR Passes (Sprint 2)'),
    );
  }
}
