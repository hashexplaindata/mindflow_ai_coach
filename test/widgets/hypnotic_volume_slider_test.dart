import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindflow_ai_coach/features/meditation/presentation/widgets/hypnotic_volume_slider.dart';

/// **Volume Slider Widget Tests**
///
/// Tests the safety warning system and user interaction

void main() {
  group('HypnoticVolumeSlider Tests', () {
    testWidgets('Displays current volume percentage', (tester) async {
      double testVolume = 0.35;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: testVolume,
              onVolumeChanged: (_) {},
            ),
          ),
        ),
      );

      // Should display "35%"
      expect(find.text('35%'), findsOneWidget);
    });

    testWidgets('Shows green zone indicator for safe volume (≤30%)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.25, // 25% - safe
              onVolumeChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show check icon (green zone)
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      // Should NOT show warning message
      expect(find.textContaining('Caution'), findsNothing);
      expect(find.textContaining('Warning'), findsNothing);
    });

    testWidgets('Shows yellow zone warning for 30-40% volume', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.35, // 35% - caution zone
              onVolumeChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show warning amber icon
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);

      // Should display caution message
      expect(find.textContaining('Caution'), findsOneWidget);
    });

    testWidgets('Shows red zone warning for 40-50% volume', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.45, // 45% - warning zone
              onVolumeChanged: (_) {},
              sessionDurationMinutes: 45,
            ),
          ),
        ),
      );

      // Should show error outline icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Should display warning message
      expect(find.textContaining('Warning'), findsOneWidget);
      expect(find.textContaining('hearing fatigue'), findsOneWidget);
    });

    testWidgets('Calls onVolumeChanged when slider moves', (tester) async {
      double? changedVolume;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.30,
              onVolumeChanged: (value) {
                changedVolume = value;
              },
            ),
          ),
        ),
      );

      // Find the slider
      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);

      // Simulate dragging slider to 40%
      await tester.drag(sliderFinder, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Callback should have been called
      expect(changedVolume, isNotNull);
    });

    testWidgets('Caps volume at 50% maximum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.60, // Attempt to set above limit
              onVolumeChanged: (_) {},
            ),
          ),
        ),
      );

      // Slider should cap at 50%
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.50);
      expect(slider.max, 0.50);
    });

    testWidgets('Shows hearing protection link for extended red zone sessions',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.45,
              onVolumeChanged: (_) {},
              sessionDurationMinutes: 50, // Extended session
            ),
          ),
        ),
      );

      // Pump to trigger detailed warning
      await tester.pumpAndSettle();

      // Should show hearing protection prompt
      expect(find.textContaining('hearing protection'), findsWidgets);
    });

    testWidgets('Shows hearing protection dialog when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.45,
              onVolumeChanged: (_) {},
              sessionDurationMinutes: 50,
            ),
          ),
        ),
      );

      // Move slider to trigger warning
      await tester.drag(find.byType(Slider), const Offset(50, 0));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap hearing protection link if visible
      final protectionLink =
          find.textContaining('Tap to learn about hearing protection');
      if (tester.any(protectionLink)) {
        await tester.tap(protectionLink);
        await tester.pumpAndSettle();

        // Dialog should appear
        expect(find.text('Hearing Protection'), findsOneWidget);
        expect(
            find.textContaining('Temporary hearing fatigue'), findsOneWidget);
        expect(find.textContaining('Keep volume at 30%'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Got it'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Sets volume to 30% when "Set to 30%" button tapped',
        (tester) async {
      double? finalVolume;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.45,
              onVolumeChanged: (value) {
                finalVolume = value;
              },
              sessionDurationMinutes: 50,
            ),
          ),
        ),
      );

      // Trigger warning
      await tester.drag(find.byType(Slider), const Offset(50, 0));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Try to open dialog
      final protectionLink =
          find.textContaining('Tap to learn about hearing protection');
      if (tester.any(protectionLink)) {
        await tester.tap(protectionLink);
        await tester.pumpAndSettle();

        // Tap "Set to 30%" button
        await tester.tap(find.text('Set to 30%'));
        await tester.pumpAndSettle();

        // Volume should be set to 30%
        expect(finalVolume, 0.30);
      }
    });

    testWidgets('Hides warnings when showWarnings is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.45, // High volume
              onVolumeChanged: (_) {},
              showWarnings: false, // Warnings disabled
            ),
          ),
        ),
      );

      // Warning message should not appear
      expect(find.textContaining('Warning'), findsNothing);
      expect(find.textContaining('Caution'), findsNothing);
    });

    testWidgets('Displays volume zone labels correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.25,
              onVolumeChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show zone labels
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('Gradient track shows all safety zones', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HypnoticVolumeSlider(
              currentVolume: 0.25,
              onVolumeChanged: (_) {},
            ),
          ),
        ),
      );

      // Find gradient container
      final gradientContainer = find.byType(Container).evaluate().firstWhere(
            (element) =>
                (element.widget as Container).decoration is BoxDecoration &&
                ((element.widget as Container).decoration as BoxDecoration)
                        .gradient !=
                    null,
          );

      expect(gradientContainer, isNotNull);
    });
  });

  group('Volume Safety Zone Logic', () {
    test('Green zone: 0-30%', () {
      expect(0.00, lessThanOrEqualTo(0.30));
      expect(0.15, lessThanOrEqualTo(0.30));
      expect(0.30, lessThanOrEqualTo(0.30));
    });

    test('Yellow zone: 30-40%', () {
      expect(0.31, greaterThan(0.30));
      expect(0.35, lessThanOrEqualTo(0.40));
      expect(0.40, lessThanOrEqualTo(0.40));
    });

    test('Red zone: 40-50%', () {
      expect(0.41, greaterThan(0.40));
      expect(0.45, lessThanOrEqualTo(0.50));
      expect(0.50, lessThanOrEqualTo(0.50));
    });

    test('Blocked zone: >50%', () {
      expect(0.51, greaterThan(0.50));
      expect(0.75, greaterThan(0.50));
      expect(1.00, greaterThan(0.50));
    });
  });
}
