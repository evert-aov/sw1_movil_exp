import 'package:flutter/material.dart';

// Pantalla esqueleto de Detalle de Experiencia
class ExperienceDetailScreen extends StatelessWidget {
  final int experienceId;

  const ExperienceDetailScreen({super.key, required this.experienceId});

  void onBookNowPressed() {
    // Firma de acción para iniciar reserva
  }

  void onJoinMatchingPressed() {
    // Firma de acción para unirse a matching si el cupo mínimo no está lleno
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Experience Detail')),
      body: Center(
        child: Text('Detail for Experience #$experienceId'),
      ),
    );
  }
}
