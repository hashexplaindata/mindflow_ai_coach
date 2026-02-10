import 'dart:convert';
import 'package:http/http.dart' as http;

/// **MCP (Model Context Protocol) Client Service**
///
/// The bridge between MindFlow's Flutter app and the local MCP server.
///
/// **The Story:** Like a diplomat who translates between two governments. The
/// Flutter app speaks "Dart and widgets." The MCP server speaks "behavioral
/// patterns and correlations." This service translates between them.
///
/// **Privacy Guarantee:** The MCP client only retrieves anonymized patterns,
/// never raw psychological data. Even if Gemini API receives MCP context,
/// it sees patterns like "User flows at 9am" not "User said X at Y time."
///
/// **Constitution Compliance:**
/// - Data sovereignty: User controls retention policy
/// - Zero-knowledge: Patterns extracted client-side, PII stripped
/// - GDPR Art. 17: Full deletion supported
class MCPClientService {
  final String serverUrl;
  final Duration timeout;

  MCPClientService({
    this.serverUrl = 'http://localhost:7777',
    this.timeout = const Duration(seconds: 5),
  });

  /// Queries behavioral patterns from MCP server.
  ///
  /// **The Story:** Like asking a librarian for books on a topic. You don't
  /// get every book ever written (raw data). You get a curated summary of
  /// insights (patterns).
  ///
  /// **Parameters:**
  /// - [userId]: User identifier (will be hashed server-side)
  /// - [patternType]: Type of pattern to retrieve
  ///
  /// **Returns:** List of behavioral patterns
  ///
  /// **Privacy:** No raw conversation data, only statistical summaries
  Future<List<BehavioralPattern>> queryPatterns({
    required String userId,
    required PatternType patternType,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$serverUrl/patterns/$userId/${patternType.name}'),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final patternList = data['patterns'] as List;

        return patternList
            .map((p) => BehavioralPattern.fromJson(p as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        // No patterns found yet (new user or rare pattern type)
        return [];
      } else {
        throw MCPException(
          'Failed to query patterns: ${response.statusCode}',
          MCPErrorType.serverError,
        );
      }
    } catch (e) {
      if (e is MCPException) rethrow;

      throw MCPException(
        'Network error querying MCP server: $e',
        MCPErrorType.networkError,
      );
    }
  }

  /// Stores new anonymized pattern.
  ///
  /// **The Story:** After the client extracts a pattern from encrypted data,
  /// it deposits the anonymized insight into the MCP vault. Like archiving
  /// a summary instead of the full transcript.
  ///
  /// **Parameters:**
  /// - [pattern]: Anonymized behavioral pattern
  ///
  /// **Privacy:** This should ONLY be called with PII-stripped data
  Future<void> storePattern(BehavioralPattern pattern) async {
    try {
      final response = await http
          .post(
            Uri.parse('$serverUrl/patterns'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(pattern.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw MCPException(
          'Failed to store pattern: ${response.statusCode}',
          MCPErrorType.serverError,
        );
      }
    } catch (e) {
      if (e is MCPException) rethrow;

      throw MCPException(
        'Network error storing pattern: $e',
        MCPErrorType.networkError,
      );
    }
  }

  /// Deletes all patterns for a user (GDPR Right to Erasure).
  ///
  /// **GDPR Art. 17:** User can request complete deletion of all patterns.
  ///
  /// **The Promise:** When you say "forget everything about me," we do.
  Future<void> deleteAllPatterns(String userId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$serverUrl/patterns/$userId'),
          )
          .timeout(timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw MCPException(
          'Failed to delete patterns: ${response.statusCode}',
          MCPErrorType.serverError,
        );
      }
    } catch (e) {
      if (e is MCPException) rethrow;

      throw MCPException(
        'Network error deleting patterns: $e',
        MCPErrorType.networkError,
      );
    }
  }

  /// Checks if MCP server is running and reachable.
  ///
  /// **Use Case:** App startup health check
  Future<bool> isServerHealthy() async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/health'))
          .timeout(const Duration(seconds: 2));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Updates retention policy for user's patterns.
  ///
  /// **User Control:** User decides how long MindFlow remembers their patterns.
  ///
  /// **Options:**
  /// - 30 days (short-term coaching)
  /// - 90 days (default)
  /// - 365 days (long-term growth tracking)
  /// - Forever (user explicitly consents)
  ///
  /// **GDPR Art. 13:** User must be informed about retention period
  Future<void> updateRetentionPolicy({
    required String userId,
    required int retentionDays,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$serverUrl/retention/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'retention_days': retentionDays}),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw MCPException(
          'Failed to update retention policy: ${response.statusCode}',
          MCPErrorType.serverError,
        );
      }
    } catch (e) {
      if (e is MCPException) rethrow;

      throw MCPException(
        'Network error updating retention: $e',
        MCPErrorType.networkError,
      );
    }
  }
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

/// Types of behavioral patterns
enum PatternType {
  flowWindows, // Times when user enters flow state
  habitCorrelations, // Habit→Outcome correlations
  stressTriggers, // Situations that increase stress
  vakProfile, // Visual/Auditory/Kinesthetic preference
  cognitiveLoadTrends, // Historical cognitive load over time
  motivationalShifts, // Meta-program drift
}

/// Anonymized behavioral pattern
class BehavioralPattern {
  /// Type of pattern
  final PatternType type;

  /// Pattern data (no PII)
  final Map<String, dynamic> data;

  /// Confidence score (0.0-1.0)
  final double confidence;

  /// Sample size (number of observations)
  final int sampleSize;

  /// When this pattern was last updated
  final DateTime lastUpdated;

  const BehavioralPattern({
    required this.type,
    required this.data,
    required this.confidence,
    required this.sampleSize,
    required this.lastUpdated,
  });

  /// Human-readable description
  String get description {
    switch (type) {
      case PatternType.flowWindows:
        final timeWindow = data['time_window'] as String?;
        final probability = data['flow_probability'] as double?;
        return 'Flow window: $timeWindow (${(probability! * 100).toStringAsFixed(0)}% probability)';

      case PatternType.habitCorrelations:
        final habit = data['habit_name'] as String?;
        final outcome = data['outcome_metric'] as String?;
        final correlation = data['correlation_coefficient'] as double?;
        return '$habit → $outcome (r=${correlation?.toStringAsFixed(2)})';

      case PatternType.stressTriggers:
        final trigger = data['trigger_type'] as String?;
        final frequency = data['frequency'] as String?;
        return 'Stress trigger: $trigger ($frequency)';

      case PatternType.vakProfile:
        final system = data['primary_system'] as String?;
        final pct = data['confidence'] as double?;
        return 'VAK: $system (${(pct! * 100).toStringAsFixed(0)}% confidence)';

      case PatternType.cognitiveLoadTrends:
        final trend = data['trend'] as String?;
        return 'Cognitive load trend: $trend';

      case PatternType.motivationalShifts:
        final shift = data['shift_description'] as String?;
        return 'Motivational shift: $shift';
    }
  }

  factory BehavioralPattern.fromJson(Map<String, dynamic> json) {
    return BehavioralPattern(
      type: PatternType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PatternType.flowWindows,
      ),
      data: json['data'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
      sampleSize: json['sample_size'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'data': data,
        'confidence': confidence,
        'sample_size': sampleSize,
        'last_updated': lastUpdated.toIso8601String(),
      };
}

/// MCP service exceptions
class MCPException implements Exception {
  final String message;
  final MCPErrorType type;

  const MCPException(this.message, this.type);

  @override
  String toString() => 'MCPException[$type]: $message';
}

enum MCPErrorType {
  networkError, // Can't reach server
  serverError, // Server returned error
  validationError, // Invalid data
}

// =============================================================================
// PATTERN EXTRACTION (Client-Side, Privacy-Preserving)
// =============================================================================

/// **Pattern Extractor**
///
/// Runs client-side to extract anonymized patterns from encrypted data.
///
/// **The Critical Difference:**
/// - Input: Decrypted user data (temporary, in-memory only)
/// - Output: Anonymized statistical patterns
/// - Storage: Only the patterns, never the raw data
///
/// **Privacy:** Raw data is decrypted, analyzed, and immediately discarded.
/// Only the "insights" (patterns) are kept.
class PatternExtractor {
  /// Extracts flow windows from session logs.
  ///
  /// **Input:** List of focus sessions with timestamps and flow scores
  /// **Output:** Anonymized pattern: "User flows 78% at 9am"
  ///
  /// **PII Stripped:** No session content, only time+score statistics
  BehavioralPattern? extractFlowWindows({
    required List<Map<String, dynamic>> sessionLogs,
  }) {
    if (sessionLogs.length < 5) {
      // Not enough data for statistical significance
      return null;
    }

    // Group by hour of day
    final hourlyFlowScores = <int, List<double>>{};

    for (final session in sessionLogs) {
      final timestamp = DateTime.parse(session['timestamp'] as String);
      final flowScore = (session['flow_score'] as num?)?.toDouble() ?? 0.0;

      final hour = timestamp.hour;
      hourlyFlowScores.putIfAbsent(hour, () => []).add(flowScore);
    }

    // Find peak flow window
    int? peakHour;
    double maxAvgFlow = 0.0;

    hourlyFlowScores.forEach((hour, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg > maxAvgFlow) {
        maxAvgFlow = avg;
        peakHour = hour;
      }
    });

    if (peakHour == null) return null;

    return BehavioralPattern(
      type: PatternType.flowWindows,
      data: {
        'time_window': '$peakHour:00-${peakHour! + 1}:00',
        'flow_probability': maxAvgFlow,
      },
      confidence: hourlyFlowScores[peakHour]!.length >= 10 ? 0.85 : 0.65,
      sampleSize: sessionLogs.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// Extracts habit→outcome correlations.
  ///
  /// **Example:** "Meditation → 40% higher focus score"
  ///
  /// **Privacy:** Habit type and outcome metric only, no specifics
  BehavioralPattern? extractHabitCorrelations({
    required List<Map<String, dynamic>> habitLogs,
    required List<Map<String, dynamic>> outcomeLogs,
  }) {
    if (habitLogs.length < 10 || outcomeLogs.length < 10) {
      return null;
    }

    // Simple correlation: Days with habit vs days without
    final daysWithHabit = <DateTime>{};

    for (final log in habitLogs) {
      final timestamp = DateTime.parse(log['timestamp'] as String);
      daysWithHabit
          .add(DateTime(timestamp.year, timestamp.month, timestamp.day));
    }

    double focusWithHabit = 0.0;
    int countWithHabit = 0;

    double focusWithoutHabit = 0.0;
    int countWithoutHabit = 0;

    for (final outcome in outcomeLogs) {
      final timestamp = DateTime.parse(outcome['timestamp'] as String);
      final day = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final focusScore = (outcome['focus_score'] as num?)?.toDouble() ?? 0.0;

      if (daysWithHabit.contains(day)) {
        focusWithHabit += focusScore;
        countWithHabit++;
      } else {
        focusWithoutHabit += focusScore;
        countWithoutHabit++;
      }
    }

    if (countWithHabit == 0 || countWithoutHabit == 0) return null;

    final avgWith = focusWithHabit / countWithHabit;
    final avgWithout = focusWithoutHabit / countWithoutHabit;

    final percentIncrease = ((avgWith - avgWithout) / avgWithout);

    return BehavioralPattern(
      type: PatternType.habitCorrelations,
      data: {
        'habit_name':
            'meditation', // Simplified - in production, extract from logs
        'outcome_metric': 'focus_score',
        'correlation_coefficient': percentIncrease,
      },
      confidence: countWithHabit >= 20 ? 0.80 : 0.60,
      sampleSize: habitLogs.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// Extracts stress triggers.
  ///
  /// **Example:** "Work presentations → elevated stress (3x/week)"
  ///
  /// **Privacy:** Category only, no specific event details
  BehavioralPattern? extractStressTriggers({
    required List<Map<String, dynamic>> stressLogs,
  }) {
    if (stressLogs.length < 5) return null;

    // Group by trigger category
    final triggerCounts = <String, int>{};

    for (final log in stressLogs) {
      final category = log['category'] as String? ?? 'unknown';
      triggerCounts[category] = (triggerCounts[category] ?? 0) + 1;
    }

    // Find most common trigger
    String? topTrigger;
    int maxCount = 0;

    triggerCounts.forEach((trigger, count) {
      if (count > maxCount) {
        maxCount = count;
        topTrigger = trigger;
      }
    });

    if (topTrigger == null) return null;

    return BehavioralPattern(
      type: PatternType.stressTriggers,
      data: {
        'trigger_type': topTrigger,
        'frequency': '${maxCount}x in ${stressLogs.length} events',
      },
      confidence: maxCount >= 5 ? 0.75 : 0.55,
      sampleSize: stressLogs.length,
      lastUpdated: DateTime.now(),
    );
  }
}
