import 'package:flutter/material.dart';

// Pantalla esqueleto de Perfil y Preferencias (CU-02)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void onUpdateProfilePressed() {
    // Firma de acción para guardar preferencias
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: const Center(
        child: Text('Profile Screen (CU-02)'),
      ),
    );
  }
}
