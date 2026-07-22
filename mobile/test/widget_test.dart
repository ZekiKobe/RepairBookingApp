<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
=======
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import 'package:flutter_test/flutter_test.dart';

import 'package:repair_booking/main.dart';

void main() {
<<<<<<< HEAD
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
=======
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RepairBookingApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  });
}
