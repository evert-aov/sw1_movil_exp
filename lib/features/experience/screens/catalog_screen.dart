import 'package:flutter/material.dart';

// Pantalla esqueleto de Catálogo y Exploración de Experiencias (CU-04)
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  void onApplyFilters() {
    // Firma de acción para aplicar filtros por cercanía o categoría
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Experiences')),
      body: const Center(
        child: Text('Catalog Screen (CU-04)'),
      ),
    );
  }
}
