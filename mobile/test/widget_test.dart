import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repair_booking/main.dart';

void main() {
  testWidgets('App boots with router shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RepairBookingApp(),
      ),
    );
    await tester.pump();
    // Splash screen schedules a 2.5s navigation timer — advance past it so the test can dispose cleanly.
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
