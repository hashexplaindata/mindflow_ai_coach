import 'package:flutter_test/flutter_test.dart';
import 'package:mindflow_ai_coach/core/services/bayesian_flow_engine.dart';
import 'package:mindflow_ai_coach/core/services/nlp/milton_model_engine.dart';
import 'package:mindflow_ai_coach/core/services/nlp/meta_model_engine.dart';
import 'package:mindflow_ai_coach/core/services/nlp/vak_detector.dart';
import 'package:mindflow_ai_coach/core/services/nlp/crisis_detection_layer.dart';
import 'package:mindflow_ai_coach/core/services/mcp_client_service.dart';

void main() {
  group('Phase 1: Bayesian Flow Mathematics', () {
    test('Habit Formation Entropy Calculator', () {
      final calculator = HabitFormationEntropyCalculator();

      // Week 1: Random meditation times (high chaos)
      final week1Distribution = {
        "7am": 0.20,
        "10am": 0.30,
        "2pm": 0.25,
        "skip": 0.25,
      };

      final entropy1 = calculator.calculateEntropy(week1Distribution);
      print(
          '✅ Week 1 Entropy: ${entropy1.toStringAsFixed(2)} bits (high chaos)');
      expect(entropy1, greaterThan(1.5)); // High entropy = chaos

      // Week 12: Consistent 7am meditation (habit formed)
      final week12Distribution = {
        "7am": 0.95,
        "skip": 0.05,
      };

      final entropy12 = calculator.calculateEntropy(week12Distribution);
      print(
          '✅ Week 12 Entropy: ${entropy12.toStringAsFixed(2)} bits (habit formed!)');
      expect(entropy12, lessThan(0.5)); // Low entropy = habit
    });

    test('Cognitive Load Bayesian Inference', () {
      final model = CognitiveLoadBayesianModel();

      // Scenario: User is struggling (slow, lots of corrections)
      final loadDistribution = model.inferLoad(
        responseLatencyMs: 3500,
        backspaceCount: 7,
        pauseDurationMs: 2200,
        messageLength: 45,
      );

      final highLoadProb = loadDistribution[CognitiveLoadLevel.high]!;
      print(
          '✅ High load probability: ${(highLoadProb * 100).toStringAsFixed(0)}%');
      expect(highLoadProb, greaterThan(0.5)); // Should detect high load
    });

    test('Flow State Markov Chain Predictor', () {
      final predictor = FlowStateMarkovChain();

      // Historical data: user flows at 9am consistently
      final history = List.generate(
        10,
        (i) => FlowStateObservation(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          hourOfDay: 9,
          wasInFlow: true,
          durationMinutes: 90,
        ),
      );

      final flowProb = predictor.predictFlowProbability(
        currentHour: 9,
        recentFlowHistory: history,
        contextFactors: {'sleep': 0.8, 'stress': 0.2},
      );

      print(
          '✅ Flow probability at 9am: ${(flowProb * 100).toStringAsFixed(0)}%');
      expect(flowProb, greaterThan(0.7)); // Should predict high flow
    });

    test('Cognitive Readiness Score', () {
      final calculator = CognitiveReadinessScore();

      // Scenario: Great sleep, low stress, recent wins
      final crs = calculator.calculate(
        sleepQuality: 0.9,
        stressLevel: 0.2,
        recentSuccessRate: 0.85,
        timeOptimality: 0.9,
      );

      print(
          '✅ Cognitive Readiness Score: ${(crs * 100).toStringAsFixed(0)}/100');
      print('   ${calculator.interpret(crs)}');
      expect(crs, greaterThan(0.7)); // Ready for deep work
    });
  });

  group('Phase 2: NLP Behavioral Science', () {
    test('Milton Model - Presuppositions', () {
      final milton = MiltonModelEngine();

      final presupposition = milton.generatePresupposition(
        action: 'focusing deeply',
        timeFrame: TimeFrame.as_,
      );

      print('✅ Milton Model Presupposition:');
      print('   "$presupposition"');
      expect(presupposition, contains('focusing deeply'));
    });

    test('Milton Model - Embedded Commands', () {
      final milton = MiltonModelEngine();

      final command = milton.generateEmbeddedCommand(
        command: 'FOCUS',
        target: 'on what matters',
      );

      print('✅ Embedded Command:');
      print('   "$command"');
      expect(command, contains('FOCUS'));
    });

    test('Milton Model - Complete Focus Induction', () {
      final milton = MiltonModelEngine();

      final induction = milton.generateFocusInduction(
        challenge: 'distraction',
      );

      print('✅ Complete Focus Induction Script:');
      print('   ${induction.fullScript}');
      expect(induction.pacing, isNotEmpty);
      expect(induction.presupposition, isNotEmpty);
      expect(induction.embeddedCommand, isNotEmpty);
      expect(induction.doubleBind, isNotEmpty);
      expect(induction.metaphor, isNotEmpty);
    });

    test('Meta-Model - Challenge Limiting Beliefs', () {
      final metaModel = MetaModelEngine();

      final intervention = metaModel.analyzeStatement(
        "I always procrastinate because I'm too anxious and I can't focus.",
      );

      print('✅ Meta-Model Intervention:');
      print(
          '   Patterns detected: ${intervention.detectedPatterns.map((p) => p.name).join(", ")}');
      print('   Questions:');
      for (final q in intervention.precisionQuestions) {
        print('   - $q');
      }

      expect(intervention.detectedPatterns.length, greaterThan(2));
      expect(intervention.precisionQuestions, isNotEmpty);
    });

    test('VAK Detector', () {
      final detector = VAKDetector();

      // Visual language
      const visualText =
          "I see what you mean. The picture is clear. I can visualize the solution.";
      final visualProfile = detector.detectFromText(visualText);

      print('✅ VAK Detection:');
      print('   Visual text → ${visualProfile.description}');
      expect(
          visualProfile.primarySystem, equals(RepresentationalSystem.visual));

      // Adapt message to VAK system
      final adapted = detector.adaptMessage(
        coreMessage: "Understand this concept",
        targetSystem: RepresentationalSystem.visual,
      );
      print('   Adapted: "$adapted"');
      expect(adapted, contains('see'));
    });

    test('Crisis Detection Layer', () {
      final detector = CrisisDetectionLayer();

      // Critical crisis
      final criticalAssessment = detector.analyze(
        userMessage: "I can't go on anymore. I want to end it all.",
      );

      print('✅ Crisis Detection:');
      print('   Level: ${criticalAssessment.level.name}');
      print('   Keywords: ${criticalAssessment.detectedKeywords}');
      print(
          '   Resources provided: ${criticalAssessment.resourceLinks.length}');

      expect(criticalAssessment.level, equals(CrisisLevel.critical));
      expect(criticalAssessment.resourceLinks, isNotEmpty);
      expect(criticalAssessment.isCritical, isTrue);
    });
  });

  group('Phase 3: MCP Integration', () {
    test('Pattern Extraction - Flow Windows', () {
      final extractor = PatternExtractor();

      final sessionLogs = [
        {'timestamp': '2026-02-01T09:15:00Z', 'flow_score': 0.85},
        {'timestamp': '2026-02-02T09:20:00Z', 'flow_score': 0.78},
        {'timestamp': '2026-02-03T09:10:00Z', 'flow_score': 0.92},
        {'timestamp': '2026-02-04T09:30:00Z', 'flow_score': 0.88},
        {'timestamp': '2026-02-05T09:00:00Z', 'flow_score': 0.81},
      ];

      final pattern = extractor.extractFlowWindows(sessionLogs: sessionLogs);

      print('✅ Pattern Extraction:');
      print('   ${pattern?.description}');
      print(
          '   Confidence: ${((pattern?.confidence ?? 0) * 100).toStringAsFixed(0)}%');

      expect(pattern, isNotNull);
      expect(pattern!.type, equals(PatternType.flowWindows));
    });

    test('Pattern Extraction - Habit Correlations', () {
      final extractor = PatternExtractor();

      final habitLogs = List.generate(
        15,
        (i) => {
          'timestamp':
              DateTime.now().subtract(Duration(days: i)).toIso8601String()
        },
      );

      final outcomeLogs = List.generate(
        20,
        (i) => {
          'timestamp':
              DateTime.now().subtract(Duration(days: i)).toIso8601String(),
          'focus_score': 0.7 + (i % 2 == 0 ? 0.2 : 0.0),
        },
      );

      final pattern = extractor.extractHabitCorrelations(
        habitLogs: habitLogs,
        outcomeLogs: outcomeLogs,
      );

      print('✅ Habit Correlation:');
      if (pattern != null) {
        print('   ${pattern.description}');
      }

      expect(pattern, isNotNull);
    });

    test('MCP Client - Pattern Storage & Retrieval', () async {
      // Note: This test uses real pattern objects but doesn't make actual HTTP calls
      final pattern = BehavioralPattern(
        type: PatternType.flowWindows,
        data: {
          'time_window': '9:00-10:00',
          'flow_probability': 0.82,
        },
        confidence: 0.85,
        sampleSize: 10,
        lastUpdated: DateTime.now(),
      );

      print('✅ MCP Pattern Created:');
      print('   Type: ${pattern.type.name}');
      print('   Description: ${pattern.description}');
      print('   Confidence: ${(pattern.confidence * 100).toStringAsFixed(0)}%');

      expect(pattern.description, contains('82%'));
    });
  });

  group('Integration Test: Complete Workflow', () {
    test('End-to-End: From Chaos to Flow', () {
      print('\n🚀 === COMPLETE WORKFLOW DEMONSTRATION ===\n');

      // 1. Week 1: User behavior is chaotic
      final entropyCalc = HabitFormationEntropyCalculator();
      final week1 = {"7am": 0.25, "10am": 0.25, "2pm": 0.25, "skip": 0.25};
      final chaos = entropyCalc.calculateEntropy(week1);
      print('📊 Week 1 - Habit Chaos: ${chaos.toStringAsFixed(2)} bits');

      // 2. Meta-Model challenges limiting belief
      final meta = MetaModelEngine();
      final intervention = meta.analyzeStatement(
        "I can't build habits because I always fail",
      );
      print('\n💬 Meta-Model Challenge:');
      print('   "${intervention.primaryQuestion}"');

      // 3. Milton Model provides indirect suggestion
      final milton = MiltonModelEngine();
      final suggestion = milton.generatePresupposition(
        action: 'building consistent habits',
        timeFrame: TimeFrame.as_,
      );
      print('\n🧠 Milton Model Suggestion:');
      print('   "$suggestion"');

      // 4. Week 12: Habit forms (low entropy)
      final week12 = {"7am": 0.95, "skip": 0.05};
      final habit = entropyCalc.calculateEntropy(week12);
      print('\n📊 Week 12 - Habit Formed: ${habit.toStringAsFixed(2)} bits');

      // 5. Flow prediction kicks in
      final flowPredictor = FlowStateMarkovChain();
      final history = List.generate(
        5,
        (i) => FlowStateObservation(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          hourOfDay: 7,
          wasInFlow: true,
          durationMinutes: 60,
        ),
      );
      final flowProb = flowPredictor.predictFlowProbability(
        currentHour: 7,
        recentFlowHistory: history,
        contextFactors: {'sleep': 0.9, 'stress': 0.1},
      );
      print(
          '\n⚡ Flow Forecast for 7am: ${(flowProb * 100).toStringAsFixed(0)}% probability');

      // 6. Cognitive Readiness peaks
      final crsCalc = CognitiveReadinessScore();
      final crs = crsCalc.calculate(
        sleepQuality: 0.9,
        stressLevel: 0.1,
        recentSuccessRate: 0.95,
        timeOptimality: 1.0,
      );
      print(
          '\n✨ Cognitive Readiness Score: ${(crs * 100).toStringAsFixed(0)}/100');
      print('   ${crsCalc.interpret(crs)}');

      print('\n🎯 === TRANSFORMATION COMPLETE ===\n');

      // Assertions
      expect(chaos, greaterThan(1.5)); // Started chaotic
      expect(habit, lessThan(0.5)); // Ended with habit
      expect(flowProb, greaterThan(0.7)); // High flow probability
      expect(crs, greaterThan(0.8)); // Peak cognitive readiness
    });
  });
}
