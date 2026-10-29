import 'package:flutter_test/flutter_test.dart';
import 'package:sensle_flutter/main.dart';

void main() {
  testWidgets('Sensle splash screen displays correctly',
      (WidgetTester tester) async {

    await tester.pumpWidget(const SensleApp());

    expect(find.text('Sensle'), findsOneWidget);
    expect(find.text('Let’s Go!'), findsOneWidget);
  });
}