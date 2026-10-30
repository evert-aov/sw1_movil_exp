import 'dart:math';

/// Identificador aleatorio de una operación o sesión efímera; no contiene identidad personal.
String newRequestKey() {
  final random = Random.secure();
  return List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}
