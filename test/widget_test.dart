// This is a basic Flutter widget test for Frown Upside Down app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frown_upside_down/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app launches successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for splash screen animations
    await tester.pumpAndSettle();
    
    // The test passes if the app builds without errors
  });
}
