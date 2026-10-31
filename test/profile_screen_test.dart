import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:experiencia_movil/core/localization/app_localizations.dart';
import 'package:experiencia_movil/features/auth/screens/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders default interest chips and allows selection without typing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(
            i18n: const AppLocalizations('es'),
            onLogout: () async {},
            onToggleTheme: () {},
            onToggleLanguage: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifica que el encabezado y subtítulo de preferencias existan
    expect(find.text('Intereses y preferencias'), findsOneWidget);

    // Verifica que los temas predeterminados aparezcan como chips
    expect(find.text('Gastronomía'), findsOneWidget);
    expect(find.text('Café de especialidad'), findsOneWidget);
    expect(find.text('Arte y Pintura'), findsOneWidget);

    // Toca el chip 'Gastronomía' para seleccionarlo con un toque sin escribir
    await tester.tap(find.text('Gastronomía'));
    await tester.pump();

    // Verifica que el chip quede en estado seleccionado
    final FilterChip chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Gastronomía'),
    );
    expect(chip.selected, isTrue);
  });
}
