import 'package:flutter_test/flutter_test.dart';
import 'package:experiencia_movil/main.dart';

void main() {
  testWidgets('Smoke test for ExperienciaApp', (WidgetTester tester) async {
    await tester.pumpWidget(const ExperienciaApp());
    expect(find.byType(ExperienciaApp), findsOneWidget);
  });
}
