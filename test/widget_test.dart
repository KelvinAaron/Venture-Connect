import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:venture_connect/screens/splash/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows the app name', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('VentureConnect'), findsOneWidget);
  });
}
