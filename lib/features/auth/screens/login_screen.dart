import 'package:flutter/material.dart';

// Pantalla esqueleto de Login (CU-01)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void onLoginPressed() {
    // Firma de acción para iniciar sesión
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(
        child: Text('Login Screen (CU-01)'),
      ),
    );
  }
}
