import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindflow_ai_coach/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Set a large surface size to avoid overflow in tests
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MindFlowApp());

    // Verify that the welcome screen appears
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('MindFlow'), findsOneWidget);

    // Reset surface size
    addTearDown(tester.view.resetPhysicalSize);
  });
}
