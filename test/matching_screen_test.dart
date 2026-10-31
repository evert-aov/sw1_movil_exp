import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:experiencia_movil/features/matching/screens/matching_screen.dart';

void main() {
  testWidgets('MatchingScreen renders spaced inputs, buttons, and matching banner', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: MatchingScreen(experienceId: 'test-exp-456'),
      ),
    );

    expect(find.text('Grupo por afinidad'), findsOneWidget);
    expect(find.text('Postularme al grupo'), findsOneWidget);
    expect(find.text('Actualizar estado del grupo'), findsOneWidget);
    expect(find.text('Reservar entradas directamente'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));

    // Verifica que los chips de zonas frecuentes estén presentes
    expect(find.text('Equipetrol'), findsOneWidget);
    expect(find.text('Centro'), findsOneWidget);

    // Toca el chip 'Equipetrol' para autocompletar la zona sin escribir texto
    await tester.tap(find.text('Equipetrol'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Equipetrol'), findsOneWidget);
  });
}
