import '../services/nlp/milton_model_engine.dart';
import '../services/nlp/meta_model_engine.dart';
import '../behavioral/behavioral_observer.dart';

/// **Dual-Stream API**
///
/// **The Innovation:** Gemini returns TWO payloads simultaneously:
/// 1. **Wisdom Stream** (user-facing): Milton Model hypnotic coaching
/// 2. **JSON Shadow** (telemetry): Psychometric data, invisible to user
///
/// **Example Response:**
/// ```
/// [WISDOM]
/// As you sit here, your mind naturally begins to filter what matters...
///
/// [JSON]
/// {"cognitive_load": 0.7, "meta_program": "toward", "intervention": "presupposition"}
/// ```
///
/// **Privacy:** JSON shadow never contains PII, only aggregated metrics

class DualStreamAPI {
  final MiltonModelEngine _milton = MiltonModelEngine();
  final MetaModelEngine _meta = MetaModelEngine();

  /// Generates dual-stream response
  Future<DualStreamResponse> generateResponse({
    required String userMessage,
    required BehavioralProfile profile,
    required List<String> conversationHistory,
  }) async {
    // Analyze user message
    final metaIntervention = _meta.analyzeStatement(userMessage);

    // Generate Milton Model wisdom
    final wisdom = _generateWisdom(
      userMessage: userMessage,
      profile: profile,
      intervention: metaIntervention,
    );

    // Generate JSON shadow (telemetry)
    final shadow = _generateShadow(
      profile: profile,
      intervention: metaIntervention,
    );

    return DualStreamResponse(
      wisdom: wisdom,
      shadow: shadow,
    );
  }

  String _generateWisdom({
    required String userMessage,
    required BehavioralProfile profile,
    required MetaModelIntervention intervention,
  }) {
    // If high cognitive load, use Milton Model (gentle)
    if (profile.cognitiveLoad > 0.7) {
      return _milton.generatePresupposition(
        action: 'finding clarity',
        timeFrame: TimeFrame.as_,
      );
    }

    // If low load, use Meta-Model (challenging)
    return intervention.primaryQuestion;
  }

  Map<String, dynamic> _generateShadow({
    required BehavioralProfile profile,
    required MetaModelIntervention intervention,
  }) {
    return {
      'cognitive_load': profile.cognitiveLoad,
      'backspace_ratio': profile.backspaceRatio,
      'avg_latency_ms': profile.averageLatency,
      'patterns_detected':
          intervention.detectedPatterns.map((p) => p.name).toList(),
      'intervention_type': profile.cognitiveLoad > 0.7 ? 'milton' : 'meta',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// **Real-Time Multidimensional Profiling**
///
/// **Dimensions Tracked:**
/// 1. Cognitive Load (0.0-1.0)
/// 2. Emotional Valence (-1.0 to +1.0)
/// 3. Rapport Score (0.0-1.0)
/// 4. Meta-Program (toward/away)
/// 5. VAK System (visual/auditory/kinesthetic)
///
/// **Updates:** Every message, real-time inference

class MultidimensionalProfile {
  double cognitiveLoad;
  double emotionalValence;
  double rapportScore;
  String metaProgram;
  String vakSystem;
  DateTime lastUpdated;

  MultidimensionalProfile({
    this.cognitiveLoad = 0.5,
    this.emotionalValence = 0.0,
    this.rapportScore = 0.5,
    this.metaProgram = 'neutral',
    this.vakSystem = 'unknown',
    required this.lastUpdated,
  });

  /// Updates profile from behavioral data
  void update({
    required BehavioralProfile behavioral,
    required String sentimentTrend,
    required String detectedMetaProgram,
    required String detectedVAK,
  }) {
    cognitiveLoad = behavioral.cognitiveLoad;
    emotionalValence = _inferValence(sentimentTrend);
    rapportScore = _calculateRapport(behavioral, sentimentTrend);
    metaProgram = detectedMetaProgram;
    vakSystem = detectedVAK;
    lastUpdated = DateTime.now();
  }

  double _inferValence(String trend) {
    if (trend == 'improving') return 0.5;
    if (trend == 'declining') return -0.5;
    return 0.0;
  }

  double _calculateRapport(BehavioralProfile profile, String trend) {
    double score = 0.0;
    if (profile.cognitiveLoad < 0.3) score += 0.4;
    if (profile.backspaceRatio < 0.2) score += 0.3;
    if (trend == 'improving') score += 0.3;
    return score.clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'cognitive_load': cognitiveLoad,
        'emotional_valence': emotionalValence,
        'rapport_score': rapportScore,
        'meta_program': metaProgram,
        'vak_system': vakSystem,
        'last_updated': lastUpdated.toIso8601String(),
      };
}

/// **Flow Forecasting Engine**
///
/// **Predicts:** When user will enter flow state (next 7 days)
/// **Accuracy Target:** >80%
///
/// **Factors:**
/// - Historical flow patterns (Markov Chain)
/// - Sleep quality
/// - Stress level
/// - Time of day
/// - Day of week
/// - Recent habit entropy

class FlowForecastingEngine {
  /// Forecasts flow probability for next 7 days
  List<FlowForecast> forecastWeek({
    required List<FlowStateObservation> history,
    required Map<String, double> contextFactors,
  }) {
    final forecasts = <FlowForecast>[];

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = DateTime.now().add(Duration(days: dayOffset));

      // Peak flow hours (from historical data)
      final peakHours = _extractPeakHours(history);

      for (final hour in peakHours) {
        final prob = _predictFlowProbability(
          hour: hour,
          dayOfWeek: date.weekday,
          history: history,
          context: contextFactors,
        );

        if (prob > 0.6) {
          // Only forecast high-probability windows
          forecasts.add(FlowForecast(
            dateTime: DateTime(date.year, date.month, date.day, hour),
            probability: prob,
            confidence: _calculateConfidence(history.length),
          ));
        }
      }
    }

    return forecasts;
  }

  List<int> _extractPeakHours(List<FlowStateObservation> history) {
    final hourCounts = <int, int>{};

    for (final obs in history) {
      if (obs.wasInFlow) {
        hourCounts[obs.hourOfDay] = (hourCounts[obs.hourOfDay] ?? 0) + 1;
      }
    }

    // Return top 3 hours
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours.take(3).map((e) => e.key).toList();
  }

  double _predictFlowProbability({
    required int hour,
    required int dayOfWeek,
    required List<FlowStateObservation> history,
    required Map<String, double> context,
  }) {
    // Base probability from historical data
    double baseProb = 0.5;

    final matchingObs = history.where((obs) => obs.hourOfDay == hour).toList();
    if (matchingObs.isNotEmpty) {
      final flowCount = matchingObs.where((obs) => obs.wasInFlow).length;
      baseProb = flowCount / matchingObs.length;
    }

    // Adjust for context
    final sleepQuality = context['sleep'] ?? 0.7;
    final stressLevel = context['stress'] ?? 0.3;

    baseProb *= sleepQuality; // High sleep = higher prob
    baseProb *= (1 - stressLevel); // High stress = lower prob

    return baseProb.clamp(0.0, 1.0);
  }

  double _calculateConfidence(int sampleSize) {
    // More data = higher confidence
    if (sampleSize < 5) return 0.3;
    if (sampleSize < 10) return 0.6;
    if (sampleSize < 20) return 0.8;
    return 0.95;
  }
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

class DualStreamResponse {
  final String wisdom; // User-facing Milton Model text
  final Map<String, dynamic> shadow; // Hidden telemetry JSON

  const DualStreamResponse({
    required this.wisdom,
    required this.shadow,
  });
}

class FlowStateObservation {
  final DateTime timestamp;
  final int hourOfDay;
  final bool wasInFlow;
  final int durationMinutes;

  const FlowStateObservation({
    required this.timestamp,
    required this.hourOfDay,
    required this.wasInFlow,
    required this.durationMinutes,
  });
}

class FlowForecast {
  final DateTime dateTime;
  final double probability;
  final double confidence;

  const FlowForecast({
    required this.dateTime,
    required this.probability,
    required this.confidence,
  });

  String get formattedTime {
    final hour = dateTime.hour;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $amPm';
  }

  String get description {
    final probPercent = (probability * 100).toStringAsFixed(0);
    return '$probPercent% flow probability at $formattedTime';
  }
}
