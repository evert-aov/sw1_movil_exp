import 'package:flutter_test/flutter_test.dart';
import 'package:experiencia_movil/main.dart';

void main() {
  testWidgets('ExperienciaApp renders correctly across platforms',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExperienciaApp());
    expect(find.text('EXPERIENCIA'), findsWidgets);
  });
}
