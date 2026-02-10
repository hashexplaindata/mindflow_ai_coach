/// **Behavioral Observer Middleware**
///
/// **The Story:** Like a clinical psychologist observing body language,
/// this middleware "watches" how users interact with the app to infer
/// their cognitive state.
///
/// **Signals Tracked:**
/// - Response latency (slow typing = high cognitive load)
/// - Backspace frequency (corrections = uncertainty/struggle)
/// - Pause durations (long pauses = decision paralysis)
/// - Message length (short messages = low engagement)
/// - Editing patterns (rewrites = perfectionism/anxiety)
///
/// **Privacy:** All observation happens client-side. Raw keystrokes are
/// NEVER logged—only aggregated metrics (average latency, backspace count).
///
/// **Constitutional Compliance:** User must consent during onboarding.
class BehavioralObserver {
  // Metrics tracked
  final List<int> _responseLatencies = [];
  final List<int> _backspaceCounts = [];
  final List<int> _pauseDurations = [];
  final List<int> _messageLengths = [];

  DateTime? _lastKeystroke;
  int _currentBackspaceCount = 0;
  int _currentMessageLength = 0;
  bool _isEnabled = true;

  /// Enables or disables observation (user control)
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      clearMetrics();
    }
  }

  /// Records a keystroke event
  void recordKeystroke({bool isBackspace = false}) {
    if (!_isEnabled) return;

    final now = DateTime.now();

    // Track response latency
    if (_lastKeystroke != null) {
      final latencyMs = now.difference(_lastKeystroke!).inMilliseconds;
      _responseLatencies.add(latencyMs);

      // Pause detection (>2 seconds = cognitive pause)
      if (latencyMs > 2000) {
        _pauseDurations.add(latencyMs);
      }
    }

    // Track backspaces (self-correction indicator)
    if (isBackspace) {
      _currentBackspaceCount++;
      if (_currentMessageLength > 0) {
        _currentMessageLength--;
      }
    } else {
      _currentMessageLength++;
    }

    _lastKeystroke = now;
  }

  /// Records message completion
  void recordMessageComplete() {
    if (!_isEnabled) return;

    _backspaceCounts.add(_currentBackspaceCount);
    _messageLengths.add(_currentMessageLength);

    // Reset for next message
    _currentBackspaceCount = 0;
    _currentMessageLength = 0;
    _lastKeystroke = null;
  }

  /// Calculates average response latency (cognitive load proxy)
  double getAverageLatency() {
    if (_responseLatencies.isEmpty) return 0;
    return _responseLatencies.reduce((a, b) => a + b) /
        _responseLatencies.length;
  }

  /// Calculates backspace ratio (uncertainty/perfectionism indicator)
  double getBackspaceRatio() {
    if (_messageLengths.isEmpty) return 0;

    final totalChars = _messageLengths.reduce((a, b) => a + b);
    final totalBackspaces = _backspaceCounts.reduce((a, b) => a + b);

    return totalBackspaces / (totalChars + totalBackspaces);
  }

  /// Calculates average pause duration (decision paralysis indicator)
  double getAveragePauseDuration() {
    if (_pauseDurations.isEmpty) return 0;
    return _pauseDurations.reduce((a, b) => a + b) / _pauseDurations.length;
  }

  /// Infers current cognitive load (0.0-1.0)
  ///
  /// **Algorithm:**
  /// - High latency (>1500ms) = +0.3 load
  /// - High backspace ratio (>0.3) = +0.3 load
  /// - Long pauses (>3000ms) = +0.4 load
  double inferCognitiveLoad() {
    double load = 0.0;

    // Latency component
    final avgLatency = getAverageLatency();
    if (avgLatency > 1500) load += 0.3;
    if (avgLatency > 3000) load += 0.2; // Cumulative, very slow

    // Backspace component (perfectionism/uncertainty)
    final backspaceRatio = getBackspaceRatio();
    if (backspaceRatio > 0.3) load += 0.3;
    if (backspaceRatio > 0.5) load += 0.2;

    // Pause component (decision paralysis)
    final avgPause = getAveragePauseDuration();
    if (avgPause > 3000) load += 0.4;

    return load.clamp(0.0, 1.0);
  }

  /// Gets behavioral profile summary
  BehavioralProfile getProfile() {
    return BehavioralProfile(
      averageLatency: getAverageLatency(),
      backspaceRatio: getBackspaceRatio(),
      averagePauseDuration: getAveragePauseDuration(),
      cognitiveLoad: inferCognitiveLoad(),
      sampleSize: _responseLatencies.length,
    );
  }

  /// Clears all metrics (for privacy or reset)
  void clearMetrics() {
    _responseLatencies.clear();
    _backspaceCounts.clear();
    _pauseDurations.clear();
    _messageLengths.clear();
    _lastKeystroke = null;
    _currentBackspaceCount = 0;
    _currentMessageLength = 0;
  }
}

/// **Sentiment Velocity Tracker**
///
/// **The Story:** Not just WHAT the user feels, but HOW FAST their mood shifts.
/// Rapid mood swings indicate emotional dysregulation (crisis risk).
///
/// **Use Case:** Crisis detection, emotional stability assessment
class SentimentVelocityTracker {
  final List<SentimentObservation> _observations = [];

  /// Records a sentiment observation
  void recordSentiment({
    required double valence, // -1.0 (negative) to +1.0 (positive)
    required DateTime timestamp,
  }) {
    _observations.add(SentimentObservation(
      valence: valence,
      timestamp: timestamp,
    ));

    // Keep only last 20 observations
    if (_observations.length > 20) {
      _observations.removeAt(0);
    }
  }

  /// Calculates sentiment velocity (change per hour)
  double calculateVelocity() {
    if (_observations.length < 2) return 0.0;

    final first = _observations.first;
    final last = _observations.last;

    final valenceDiff = last.valence - first.valence;
    final timeDiff =
        last.timestamp.difference(first.timestamp).inMinutes / 60.0;

    if (timeDiff == 0) return 0.0;

    return valenceDiff / timeDiff; // Units: valence per hour
  }

  /// Detects rapid mood swings (crisis indicator)
  bool isVolatile() {
    final velocity = calculateVelocity().abs();
    return velocity > 0.5; // >0.5 valence shift per hour = volatile
  }

  /// Gets sentiment trend
  String getTrend() {
    if (_observations.length < 2) return 'insufficient_data';

    final velocity = calculateVelocity();

    if (velocity > 0.3) return 'improving';
    if (velocity < -0.3) return 'declining';
    return 'stable';
  }
}

/// **Rapport Scoring Algorithm**
///
/// **The Story:** Like a therapist sensing when they've "clicked" with a client.
/// High rapport = user trusts the AI, messages are longer, latency is lower.
///
/// **Metrics:**
/// - Message length (longer = more engaged)
/// - Response latency (faster = more engaged)
/// - Backspace ratio (lower = less self-conscious)
/// - Sentiment trajectory (improving = rapport building)
///
/// **Target:** >0.85 rapport score before advanced interventions
class RapportScoringAlgorithm {
  /// Calculates rapport score (0.0-1.0)
  double calculateRapport({
    required BehavioralProfile profile,
    required String sentimentTrend,
  }) {
    double score = 0.0;

    // Component 1: Low cognitive load (comfortable, not struggling)
    if (profile.cognitiveLoad < 0.3) {
      score += 0.30;
    } else if (profile.cognitiveLoad < 0.5) {
      score += 0.15;
    }

    // Component 2: Low backspace ratio (not self-conscious)
    if (profile.backspaceRatio < 0.2) {
      score += 0.25;
    } else if (profile.backspaceRatio < 0.4) {
      score += 0.10;
    }

    // Component 3: Moderate latency (engaged but thoughtful)
    if (profile.averageLatency > 500 && profile.averageLatency < 2000) {
      score += 0.25;
    }

    // Component 4: Sentiment improving (building trust)
    if (sentimentTrend == 'improving') {
      score += 0.20;
    } else if (sentimentTrend == 'stable') {
      score += 0.10;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Checks if rapport is sufficient for advanced interventions
  bool isRapportSufficient(double rapportScore) {
    return rapportScore >= 0.85;
  }

  /// Gets rapport interpretation
  String interpretRapport(double score) {
    if (score >= 0.85) return 'Strong rapport - ready for deep work';
    if (score >= 0.7) return 'Good rapport - building trust';
    if (score >= 0.5) return 'Moderate rapport - continue pacing';
    return 'Low rapport - focus on safety and validation';
  }
}

/// **Meta-Program Drift Detector**
///
/// **The Story:** Meta-programs are unconscious thinking patterns (e.g.,
/// "toward goals" vs "away from problems"). They shift under stress.
/// Detecting drift = early warning of crisis.
///
/// **Example:** User normally talks about goals ("I want to focus").
/// Under stress, shifts to problems ("I can't stop failing").
class MetaProgramDriftDetector {
  // Historical baseline (first 10 messages)
  String? _baselineMetaProgram;

  /// Detects meta-program from text
  String detectMetaProgram(String text) {
    final lowerText = text.toLowerCase();

    // Toward (goals, achievements)
    final towardKeywords = ['want', 'achieve', 'build', 'create', 'grow'];
    final towardCount =
        towardKeywords.where((k) => lowerText.contains(k)).length;

    // Away (problems, avoidance)
    final awayKeywords = ['avoid', 'prevent', 'stop', 'fix', 'problem'];
    final awayCount = awayKeywords.where((k) => lowerText.contains(k)).length;

    if (towardCount > awayCount) return 'toward';
    if (awayCount > towardCount) return 'away';
    return 'neutral';
  }

  /// Sets baseline meta-program
  void setBaseline(String metaProgram) {
    _baselineMetaProgram = metaProgram;
  }

  /// Detects if meta-program has drifted (stress indicator)
  bool hasDrifted(String currentMetaProgram) {
    if (_baselineMetaProgram == null) return false;
    return currentMetaProgram != _baselineMetaProgram;
  }
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

class BehavioralProfile {
  final double averageLatency;
  final double backspaceRatio;
  final double averagePauseDuration;
  final double cognitiveLoad;
  final int sampleSize;

  const BehavioralProfile({
    required this.averageLatency,
    required this.backspaceRatio,
    required this.averagePauseDuration,
    required this.cognitiveLoad,
    required this.sampleSize,
  });

  Map<String, dynamic> toJson() => {
        'average_latency_ms': averageLatency,
        'backspace_ratio': backspaceRatio,
        'average_pause_ms': averagePauseDuration,
        'cognitive_load': cognitiveLoad,
        'sample_size': sampleSize,
      };
}

class SentimentObservation {
  final double valence;
  final DateTime timestamp;

  const SentimentObservation({
    required this.valence,
    required this.timestamp,
  });
}
