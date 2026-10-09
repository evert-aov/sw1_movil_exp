import 'package:flutter/material.dart';

// Pantalla esqueleto de Registro (CU-01)
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void onRegisterPressed() {
    // Firma de acción para registrar cuenta
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(
        child: Text('Register Screen (CU-01)'),
      ),
    );
  }
}
