import 'package:flutter_test/flutter_test.dart';

import 'package:mindflow_ai_coach/core/audio/frequency_protocols.dart';
import 'package:mindflow_ai_coach/core/audio/ai_music_generator.dart';

/// **AUTOMATED TEST SUITE**
///
/// Comprehensive testing of the Advanced Hypnotic Audio System
/// Tests protocols, safety mechanisms, and frequency accuracy
/// Updated to use ProtocolLibrary and TherapeuticProtocol

void main() {
  group('Advanced Hypnotic Audio Service Tests', () {
    group('Protocol Library Tests', () {
      test('Protocol Library contains core protocols', () {
        final protocols = ProtocolLibrary.allProtocols;
        expect(protocols.length, greaterThanOrEqualTo(6));

        expect(protocols.any((p) => p.id == ProtocolLibrary.focusProtocol.id),
            true);
        expect(protocols.any((p) => p.id == ProtocolLibrary.sleepProtocol.id),
            true);
        expect(
            protocols.any((p) => p.id == ProtocolLibrary.meditationProtocol.id),
            true);
        expect(
            protocols
                .any((p) => p.id == ProtocolLibrary.anxietyReliefProtocol.id),
            true);
      });

      test('Deep Focus protocol configuration', () {
        const protocol = ProtocolLibrary.focusProtocol;
        expect(protocol.name, contains('Focus'));
        expect(protocol.steps, isNotEmpty);

        // Verify Gamma phase (40 Hz)
        expect(protocol.steps.any((s) => s.frequency == 40.0), true);
      });

      test('Deep Sleep protocol configuration', () {
        const protocol = ProtocolLibrary.sleepProtocol;
        // Verify it descends to Delta
        expect(protocol.steps.last.frequency, lessThanOrEqualTo(2.0));
      });

      test('Meditation protocol uses Schumann Resonance (7.83 Hz)', () {
        const protocol = ProtocolLibrary.meditationProtocol;
        expect(
            protocol.steps.any((s) => s.frequency == SchumannResonance.primary),
            true);
      });

      test('Meditation protocol contains Shamanic 4.5 Hz phase', () {
        const protocol = ProtocolLibrary.meditationProtocol;
        expect(protocol.steps.any((s) => s.frequency == 4.5), true);
      });
    });

    group('Protocol Structure Analysis', () {
      test('All protocols have valid structure', () {
        for (final protocol in ProtocolLibrary.allProtocols) {
          expect(protocol.totalDurationMinutes, greaterThan(0));
          expect(protocol.steps, isNotEmpty);
          for (final step in protocol.steps) {
            expect(step.durationSeconds, greaterThan(0));
            expect(step.frequency, greaterThan(0));
            expect(step.volumeMultiplier, greaterThanOrEqualTo(0.0));
            expect(step.volumeMultiplier, lessThanOrEqualTo(1.0));
          }
        }
      });
    });

    group('Frequency Safety Validation', () {
      test('Deep Sleep goes to very low delta but stays > 0', () {
        const protocol = ProtocolLibrary.sleepProtocol;
        for (var step in protocol.steps) {
          expect(step.frequency, greaterThan(0.0));
        }
        expect(protocol.steps.any((s) => s.frequency <= 1.0), true);
      });
    });

    group('AI Music Generator Tests', () {
      final generator = AIMusicGenerator();

      test('Selects correct protocol for "focus"', () {
        final protocol = generator.selectProtocolForGoal('I need to focus');
        expect(protocol.id, ProtocolLibrary.focusProtocol.id);
      });

      test('Selects correct protocol for "sleep"', () {
        final protocol = generator.selectProtocolForGoal('help me sleep');
        expect(protocol.id, ProtocolLibrary.sleepProtocol.id);
      });

      test('Selects anxiety relief for "calm"', () {
        // "calm" maps to anxietyReliefProtocol in selectProtocolForGoal
        final protocol = generator.selectProtocolForGoal('I want to be calm');
        expect(protocol.id, ProtocolLibrary.anxietyReliefProtocol.id);
      });

      test('Selects meditation for "spiritual"', () {
        final protocol = generator.selectProtocolForGoal('spiritual growth');
        expect(protocol.id, ProtocolLibrary.meditationProtocol.id);
      });
    });

    group('Circadian Optimization Logic', () {
      final generator = AIMusicGenerator();
      const protocol = ProtocolLibrary.focusProtocol; // BPM 80

      test('Morning Optimizes BPM UP', () {
        final morning = DateTime(2023, 1, 1, 8, 0); // 8 AM
        final optimized = generator.optimizeForTimeOfDay(protocol, morning);
        expect(optimized.bpm, 85);
      });

      test('Night Optimizes BPM DOWN', () {
        final night = DateTime(2023, 1, 1, 23, 0); // 11 PM
        final optimized = generator.optimizeForTimeOfDay(protocol, night);
        expect(optimized.bpm, 60);
      });
    });
  });
}
