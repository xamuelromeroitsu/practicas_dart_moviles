// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('PingPongApp builds and shows main menu', (WidgetTester tester) async {
    await tester.pumpWidget(const PingPongApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify the main menu appears
    expect(find.text('PING PONG PRO'), findsOneWidget);
    expect(find.text('MULTIJUGADOR (PvP)'), findsOneWidget);
    expect(find.text('CONTRA LA IA (PvE)'), findsOneWidget);
  });
}