import 'package:flutter/material.dart';

/// Pantalla esqueleto de Matching Grupal Dinámico (Planificada para Sprint 2 • CU-07).
///
/// Conserva el contrato de interfaz para el módulo de agrupación por intereses.
class MatchingScreen extends StatelessWidget {
  /// Crea una instancia de [MatchingScreen].
  const MatchingScreen({super.key});

  /// Firma de acción para postular interés grupal a una experiencia.
  void onApplyQuorumPressed() {}

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dynamic Group Matching (Sprint 2)'),
    );
  }
}
