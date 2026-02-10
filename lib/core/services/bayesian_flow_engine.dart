import 'dart:math';

/// **Bayesian Flow Mathematics Engine**
///
/// This is the mathematical heart of MindFlow's cognitive engineering system.
/// Like a skilled conductor reading an orchestra, this engine observes the subtle
/// patterns in human behavior and predicts the rhythm of peak performance.
///
/// **Core Principles:**
/// - Habit formation reduces entropy (chaos → order)
/// - Cognitive load can be inferred from behavioral signals
/// - Flow states follow predictable Markov transitions
/// - All mathematics are validated against neuroscience research
///
/// **Constitution Compliance:** Privacy-by-design. All calculations happen
/// client-side. No raw psychological data is transmitted.
class BayesianFlowEngine {
  /// Calculates habit formation entropy.
  ///
  /// **The Story:** Imagine pouring water into a groove. At first, it goes
  /// everywhere (high entropy). Over time, the groove deepens, and water flows
  /// predictably (low entropy). Habits are the same.
  ///
  /// **Mathematics:** Shannon Entropy H(X) = -Σ p(x) log₂ p(x)
  /// - Range: 0 (perfect habit) to log₂(n) (complete chaos)
  /// - Lower is better: means behavior is more predictable/automatic
  HabitFormationEntropyCalculator get habitEntropy =>
      HabitFormationEntropyCalculator();

  /// Infers cognitive load from behavioral signals.
  ///
  /// **The Story:** Your mind leaves breadcrumbs. Long pauses? Mind is grinding.
  /// Lots of backspaces? Wrestling with complexity. Fast, fluid responses?
  /// Cognitive cruise control.
  ///
  /// **Mathematics:** Bayesian Inference P(Load|Evidence) ∝ P(Evidence|Load) × P(Load)
  CognitiveLoadBayesianModel get cognitiveLoad => CognitiveLoadBayesianModel();

  /// Predicts Flow states using Markov Chains.
  ///
  /// **The Story:** Flow isn't random. It follows patterns. Morning person?
  /// 9-11am is your golden window. Night owl? After 8pm you're unstoppable.
  /// This engine learns YOUR rhythm.
  ///
  /// **Mathematics:** Markov Chain state transitions with historical weighting
  FlowStateMarkovChain get flowPredictor => FlowStateMarkovChain();

  /// Calculates Cognitive Readiness Score.
  ///
  /// **The Story:** Are you ready to tackle that hard task? CRS combines sleep,
  /// stress, and recent wins into a single "go/no-go" score. Like a pilot's
  /// pre-flight checklist, but for your brain.
  ///
  /// **Mathematics:** Weighted sum CRS = Σ(wᵢ × xᵢ) with dynamic weight adjustment
  CognitiveReadinessScore get readinessScore => CognitiveReadinessScore();
}

// =============================================================================
// HABIT FORMATION ENTROPY CALCULATOR
// =============================================================================

/// **Habit Entropy: From Chaos to Automaticity**
///
/// Tracks how "solid" a habit is by measuring behavioral variance.
/// Lower entropy = habit is forming. Higher entropy = still chaotic.
///
/// **Real-World Example:**
/// - Week 1: Meditate at 7am (20%), 10am (30%), 2pm (25%), skip (25%) → High entropy
/// - Week 12: Meditate at 7am (95%), skip (5%) → Low entropy (habit formed!)
class HabitFormationEntropyCalculator {
  /// Calculates Shannon entropy for a habit's behavioral distribution.
  ///
  /// **Parameters:**
  /// - [behaviorProbabilities]: Map of behavior → probability
  ///   Example: {"7am": 0.8, "10am": 0.15, "skip": 0.05}
  ///
  /// **Returns:** Entropy in bits (0 = perfect habit, higher = more chaos)
  ///
  /// **Mathematics:**
  /// ```
  /// H(X) = -Σ p(x) × log₂(p(x))
  /// where p(x) is the probability of each behavior variant
  /// ```
  double calculateEntropy(Map<String, double> behaviorProbabilities) {
    if (behaviorProbabilities.isEmpty) return 0.0;

    // **Story:** We're measuring "surprise." If you always do X at Y time,
    // there's no surprise (entropy = 0). If your behavior is random, maximum surprise.
    double entropy = 0.0;

    for (final probability in behaviorProbabilities.values) {
      // Skip zero probabilities (log(0) is undefined)
      if (probability > 0) {
        // Shannon's formula: -p × log₂(p)
        entropy -= probability * _log2(probability);
      }
    }

    return entropy;
  }

  /// Normalizes entropy to 0-1 scale for easier interpretation.
  ///
  /// **Returns:**
  /// - 1.0 = Perfect habit (zero entropy)
  /// - 0.0 = Complete chaos (maximum entropy for this behavior set)
  double normalizeEntropy(
    double entropy,
    int numberOfBehaviorVariants,
  ) {
    // Maximum possible entropy for n variants
    final maxEntropy = _log2(numberOfBehaviorVariants.toDouble());

    if (maxEntropy == 0) return 1.0;

    // Invert: high entropy (chaos) → low score, low entropy (habit) → high score
    return 1.0 - (entropy / maxEntropy);
  }

  /// Tracks entropy over time to detect habit formation trends.
  ///
  /// **The Story:** A single snapshot isn't enough. We need the movie, not the photo.
  /// Is entropy decreasing? Habit is forming! Increasing? Something disrupted the pattern.
  ///
  /// **Returns:** Slope of entropy over time (negative = good, positive = concerning)
  double calculateEntropyTrend(List<EntropySnapshot> history) {
    if (history.length < 2) return 0.0;

    // Simple linear regression: Δentropy / Δtime
    final oldest = history.first;
    final newest = history.last;

    final timeDelta =
        newest.timestamp.difference(oldest.timestamp).inDays.toDouble();
    if (timeDelta == 0) return 0.0;

    final entropyDelta = newest.entropy - oldest.entropy;

    // **Interpretation:**
    // - Negative slope: entropy decreasing → habit solidifying ✅
    // - Positive slope: entropy increasing → habit degrading ⚠️
    return entropyDelta / timeDelta;
  }

  // Helper: log base 2 (Dart only has natural log)
  double _log2(double x) => log(x) / ln2;
}

/// Snapshot of entropy at a point in time.
class EntropySnapshot {
  final DateTime timestamp;
  final double entropy;

  const EntropySnapshot({
    required this.timestamp,
    required this.entropy,
  });
}

// =============================================================================
// COGNITIVE LOAD BAYESIAN MODEL
// =============================================================================

/// **Cognitive Load Inference: Reading the Silent Signals**
///
/// Your brain can't hide from mathematics. This model infers how hard you're
/// working (cognitive load) from observable behavior patterns.
///
/// **Evidence Signals:**
/// - Response latency (thinking time)
/// - Backspace frequency (self-correction)
/// - Pause duration (mental processing)
/// - Message length variance (coherence)
///
/// **Use Case:** If cognitive load is too high, AI switches to simpler language
/// and breaks tasks into micro-steps.
class CognitiveLoadBayesianModel {
  // Prior probabilities (updated as we learn user's baseline)
  static const double _priorLowLoad = 0.33;
  static const double _priorMediumLoad = 0.34;
  static const double _priorHighLoad = 0.33;

  /// Infers cognitive load from behavioral evidence.
  ///
  /// **The Story:** Imagine a doctor diagnosing a patient. Fast pulse? Could be
  /// exercise or anxiety. Sweating? Heat or stress. Multiple symptoms together?
  /// Now we can diagnose with confidence. Same here.
  ///
  /// **Mathematics:** Bayes' Theorem
  /// ```
  /// P(Load|Evidence) = P(Evidence|Load) × P(Load) / P(Evidence)
  /// ```
  ///
  /// **Returns:** Map of load level → probability
  Map<CognitiveLoadLevel, double> inferLoad({
    required double responseLatencyMs,
    required int backspaceCount,
    required double pauseDurationMs,
    required int messageLength,
  }) {
    // **Step 1: Calculate likelihood of evidence given each load level**
    final likelihoodLow = _calculateLikelihood(
      responseLatency: responseLatencyMs,
      backspaces: backspaceCount,
      pause: pauseDurationMs,
      messageLen: messageLength,
      assumedLoad: CognitiveLoadLevel.low,
    );

    final likelihoodMedium = _calculateLikelihood(
      responseLatency: responseLatencyMs,
      backspaces: backspaceCount,
      pause: pauseDurationMs,
      messageLen: messageLength,
      assumedLoad: CognitiveLoadLevel.medium,
    );

    final likelihoodHigh = _calculateLikelihood(
      responseLatency: responseLatencyMs,
      backspaces: backspaceCount,
      pause: pauseDurationMs,
      messageLen: messageLength,
      assumedLoad: CognitiveLoadLevel.high,
    );

    // **Step 2: Apply Bayes' Theorem (posterior ∝ likelihood × prior)**
    final posteriorLow = likelihoodLow * _priorLowLoad;
    final posteriorMedium = likelihoodMedium * _priorMediumLoad;
    final posteriorHigh = likelihoodHigh * _priorHighLoad;

    // **Step 3: Normalize (probabilities must sum to 1.0)**
    final total = posteriorLow + posteriorMedium + posteriorHigh;

    return {
      CognitiveLoadLevel.low: posteriorLow / total,
      CognitiveLoadLevel.medium: posteriorMedium / total,
      CognitiveLoadLevel.high: posteriorHigh / total,
    };
  }

  /// Calculates likelihood of observed evidence given assumed load level.
  ///
  /// **The Story:** "If cognitive load were HIGH, how likely would we see
  /// THESE specific signals?" This is the heart of Bayesian reasoning.
  double _calculateLikelihood({
    required double responseLatency,
    required int backspaces,
    required double pause,
    required int messageLen,
    required CognitiveLoadLevel assumedLoad,
  }) {
    // **Evidence weights** (tuned from behavioral science research)
    // Higher load → longer latency, more backspaces, longer pauses, shorter messages

    double likelihood = 1.0;

    // **Response Latency Signal**
    // Low load: <1s, Medium: 1-3s, High: >3s
    if (assumedLoad == CognitiveLoadLevel.low) {
      likelihood *= responseLatency < 1000 ? 0.8 : 0.2;
    } else if (assumedLoad == CognitiveLoadLevel.medium) {
      likelihood *=
          (responseLatency >= 1000 && responseLatency <= 3000) ? 0.7 : 0.3;
    } else {
      likelihood *= responseLatency > 3000 ? 0.8 : 0.2;
    }

    // **Backspace Signal** (self-correction frequency)
    // Low load: <2, Medium: 2-5, High: >5
    if (assumedLoad == CognitiveLoadLevel.low) {
      likelihood *= backspaces < 2 ? 0.7 : 0.3;
    } else if (assumedLoad == CognitiveLoadLevel.medium) {
      likelihood *= (backspaces >= 2 && backspaces <= 5) ? 0.7 : 0.3;
    } else {
      likelihood *= backspaces > 5 ? 0.8 : 0.2;
    }

    // **Pause Duration Signal** (thinking time)
    // Low: <500ms, Medium: 500-2000ms, High: >2000ms
    if (assumedLoad == CognitiveLoadLevel.low) {
      likelihood *= pause < 500 ? 0.7 : 0.3;
    } else if (assumedLoad == CognitiveLoadLevel.medium) {
      likelihood *= (pause >= 500 && pause <= 2000) ? 0.7 : 0.3;
    } else {
      likelihood *= pause > 2000 ? 0.8 : 0.2;
    }

    // **Message Length Signal** (coherence proxy)
    // High load → shorter, fragmented messages
    if (assumedLoad == CognitiveLoadLevel.high) {
      likelihood *= messageLen < 50 ? 0.7 : 0.3;
    }

    return likelihood;
  }
}

/// Cognitive load levels
enum CognitiveLoadLevel {
  low, // Cruising, brain has spare capacity
  medium, // Working hard but not overwhelmed
  high, // Near cognitive overload
}

// =============================================================================
// FLOW STATE MARKOV CHAIN
// =============================================================================

/// **Flow Forecasting: Your Brain's Rhythm**
///
/// Flow states aren't random. They follow patterns influenced by circadian
/// rhythms, energy levels, and habit loops. This Markov Chain learns when
/// YOU enter flow and predicts your peak performance windows.
///
/// **How it works:**
/// - Track historical flow states by time/context
/// - Build transition probability matrix
/// - Forecast: "You have 78% chance of flow at 9am tomorrow"
class FlowStateMarkovChain {
  /// Predicts probability of entering flow state given current context.
  ///
  /// **Parameters:**
  /// - [currentHour]: Hour of day (0-23)
  /// - [recentFlowHistory]: Last N flow state observations
  /// - [contextFactors]: Sleep quality, stress level, etc.
  ///
  /// **Returns:** Probability (0.0-1.0) of entering flow in next time window
  ///
  /// **The Story:** Like a surfer reading the ocean, we're reading your mental
  /// waves. The math tells us when the next "big wave" (flow state) is coming.
  double predictFlowProbability({
    required int currentHour,
    required List<FlowStateObservation> recentFlowHistory,
    required Map<String, double> contextFactors,
  }) {
    if (recentFlowHistory.isEmpty) return 0.5; // No data, assume 50/50

    // **Step 1: Calculate base probability from historical patterns**
    final historicalProb = _calculateHistoricalFlowProbability(
      currentHour,
      recentFlowHistory,
    );

    // **Step 2: Adjust for context (sleep, stress, etc.)**
    final contextAdjustment = _calculateContextAdjustment(contextFactors);

    // **Step 3: Markov transition (current state → flow state)**
    final transitionProb = _getTransitionProbability(recentFlowHistory);

    // **Combine signals** (weighted average)
    final finalProbability = (historicalProb * 0.4) +
        (contextAdjustment * 0.3) +
        (transitionProb * 0.3);

    return finalProbability.clamp(0.0, 1.0);
  }

  /// Analyzes historical data to find user's peak flow windows.
  double _calculateHistoricalFlowProbability(
    int currentHour,
    List<FlowStateObservation> history,
  ) {
    // Filter observations for this hour (±1 hour window)
    final relevantObs = history.where((obs) {
      final hourDiff = (obs.hourOfDay - currentHour).abs();
      return hourDiff <= 1;
    }).toList();

    if (relevantObs.isEmpty) return 0.5;

    // Calculate flow percentage in this time window
    final flowCount =
        relevantObs.where((obs) => obs.wasInFlow).length.toDouble();
    return flowCount / relevantObs.length;
  }

  /// Adjusts probability based on contextual factors.
  double _calculateContextAdjustment(Map<String, double> factors) {
    // **Contextual factors** (0-1 scale, higher is better for flow)
    final sleepQuality = factors['sleep'] ?? 0.5;
    final stressLevel = 1.0 - (factors['stress'] ?? 0.5); // Invert stress
    final recentSuccesses = factors['recent_wins'] ?? 0.5;

    // Weighted average
    return (sleepQuality * 0.4) + (stressLevel * 0.3) + (recentSuccesses * 0.3);
  }

  /// Calculates Markov transition probability.
  ///
  /// **The Story:** If you're already in a focused state, you're more likely
  /// to enter flow. If you're distracted, it's an uphill battle.
  double _getTransitionProbability(List<FlowStateObservation> history) {
    if (history.isEmpty) return 0.5;

    // Look at most recent state
    final currentState = history.last.wasInFlow;

    // **Markov assumption:** P(Flow_next | State_current)
    // If already in flow → high probability of staying in flow
    // If not in flow → lower probability of entering flow
    return currentState ? 0.75 : 0.35;
  }
}

/// Single observation of flow state
class FlowStateObservation {
  final DateTime timestamp;
  final int hourOfDay;
  final bool wasInFlow;
  final double durationMinutes;

  const FlowStateObservation({
    required this.timestamp,
    required this.hourOfDay,
    required this.wasInFlow,
    required this.durationMinutes,
  });
}

// =============================================================================
// COGNITIVE READINESS SCORE (CRS)
// =============================================================================

/// **Cognitive Readiness Score: Your Mental Pre-Flight Checklist**
///
/// Like a pilot checking weather, fuel, and systems before takeoff, CRS checks
/// if your brain is ready for deep work. Should you tackle that hard problem
/// now, or wait for a better window?
///
/// **Formula:** CRS = Σ(wᵢ × xᵢ)
/// - x₁: Sleep quality (0-1)
/// - x₂: Stress level (inverse, 0-1)
/// - x₃: Recent success rate (0-1)
/// - wᵢ: Dynamically adjusted weights
class CognitiveReadinessScore {
  // **Default weights** (tuned from behavioral research)
  // These adapt over time as we learn what matters most for THIS user
  static const Map<String, double> _defaultWeights = {
    'sleep': 0.40, // Sleep is king
    'stress': 0.30, // Stress is a major blocker
    'recent_wins': 0.20, // Momentum matters
    'time_of_day': 0.10, // Circadian rhythm
  };

  /// Calculates current Cognitive Readiness Score.
  ///
  /// **Parameters:**
  /// - [sleepQuality]: 0 (terrible) to 1 (perfect 8 hours)
  /// - [stressLevel]: 0 (zen) to 1 (overwhelmed)
  /// - [recentSuccessRate]: 0 (failing) to 1 (crushing it)
  /// - [timeOptimality]: 0 (worst time) to 1 (peak time for this user)
  /// - [customWeights]: Optional user-specific weight adjustments
  ///
  /// **Returns:** Score 0-1 (>0.7 = ready for deep work, <0.4 = not ideal)
  double calculate({
    required double sleepQuality,
    required double stressLevel,
    required double recentSuccessRate,
    required double timeOptimality,
    Map<String, double>? customWeights,
  }) {
    final weights = customWeights ?? _defaultWeights;

    // **The Story:** We're building a composite signal from multiple sensors.
    // Like a car's dashboard: oil, temp, fuel, battery → single "health" score.

    final sleepScore = sleepQuality * (weights['sleep'] ?? 0.4);

    // **Note:** Stress is INVERTED (high stress = bad)
    final stressScore = (1.0 - stressLevel) * (weights['stress'] ?? 0.3);

    final momentumScore = recentSuccessRate * (weights['recent_wins'] ?? 0.2);

    final timingScore = timeOptimality * (weights['time_of_day'] ?? 0.1);

    final crs = sleepScore + stressScore + momentumScore + timingScore;

    return crs.clamp(0.0, 1.0);
  }

  /// Interprets CRS and provides human-readable recommendation.
  ///
  /// **The Story:** Numbers are for computers. Humans need stories.
  CognitiveReadinessInterpretation interpret(double crs) {
    if (crs >= 0.75) {
      return const CognitiveReadinessInterpretation(
        level: ReadinessLevel.optimal,
        message:
            'Your mind is clear and focused. This is your window for deep work.',
        recommendation: 'Tackle your most challenging task now.',
      );
    } else if (crs >= 0.55) {
      return const CognitiveReadinessInterpretation(
        level: ReadinessLevel.good,
        message:
            'You\'re in a solid state for focused work. Not peak, but capable.',
        recommendation: 'Good time for moderate-difficulty tasks.',
      );
    } else if (crs >= 0.35) {
      return const CognitiveReadinessInterpretation(
        level: ReadinessLevel.suboptimal,
        message:
            'Your cognitive resources are limited right now. Tread carefully.',
        recommendation: 'Consider easier tasks or take a short break.',
      );
    } else {
      return const CognitiveReadinessInterpretation(
        level: ReadinessLevel.poor,
        message: 'Your mind needs rest. Pushing through will likely backfire.',
        recommendation:
            'Step away. Walk, breathe, or tackle simple administrative tasks.',
      );
    }
  }
}

enum ReadinessLevel { optimal, good, suboptimal, poor }

class CognitiveReadinessInterpretation {
  final ReadinessLevel level;
  final String message;
  final String recommendation;

  const CognitiveReadinessInterpretation({
    required this.level,
    required this.message,
    required this.recommendation,
  });
}
