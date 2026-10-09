import 'package:flutter/material.dart';

// Pantalla esqueleto de Matching Grupal (CU-07)
class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  void onApplyQuorumPressed() {
    // Firma de acción para enviar postulación de interés grupal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Matching')),
      body: const Center(
        child: Text('Matching & Quorum Screen (CU-07)'),
      ),
    );
  }
}
