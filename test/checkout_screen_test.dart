import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:experiencia_movil/features/booking/screens/checkout_screen.dart';

void main() {
  testWidgets('CheckoutScreen renders ticket selection mode with styled stepper and price preview', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CheckoutScreen(
          experienceId: 'test-exp-123',
          initialTitle: 'Cata de Café Especial',
          initialPrice: 50.0,
        ),
      ),
    );

    // Header and title
    expect(find.text('Reserva y pago'), findsOneWidget);
    expect(find.text('Cata de Café Especial'), findsOneWidget);
    expect(find.text('CANTIDAD DE ENTRADAS'), findsOneWidget);

    // Initial quantity is 1
    expect(find.text('1'), findsOneWidget);
    expect(find.text('entrada'), findsOneWidget);
    expect(find.text('Bs. 50.00'), findsOneWidget);
    expect(find.text('Reservar 1 entrada'), findsOneWidget);

    // Increment quantity to 2
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('entradas'), findsOneWidget);
    expect(find.text('Bs. 100.00'), findsOneWidget);
    expect(find.text('Reservar 2 entradas'), findsOneWidget);

    // Hold assurance card
    expect(find.text('Retención temporal de cupos'), findsOneWidget);
  });
}
