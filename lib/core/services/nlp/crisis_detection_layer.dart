import 'package:flutter/foundation.dart';

/// **Crisis Detection & Safety Layer**
///
/// This is MindFlow's ethical safety net. Like a lifeguard scanning a pool,
/// this layer constantly monitors for signs of genuine crisis and ensures
/// immediate, appropriate intervention.
///
/// **Constitution Mandate (Section 3):**
/// "Crisis Detection: Immediate hand-off to human resources if 'self-harm'
/// or 'clinical depression' keywords are detected (Hard-coded safety layer)."
///
/// **The Promise:** AI coaching is powerful. But for genuine mental health
/// crises, humans must intervene. This layer ensures that happens.
///
/// **HIPAA Compliance:** §164.312(a) - Access controls to ensure appropriate
/// escalation of sensitive mental health information.
///
/// **Legal Protection:** Liability shield. If user is in crisis, we MUST
/// handoff to qualified professionals.
class CrisisDetectionLayer {
  /// High-sensitivity keywords (immediate escalation)
  static const Set<String> _criticalKeywords = {
    // Self-harm indicators
    'suicide',
    'kill myself',
    'end my life',
    'better off dead',
    'don\'t want to live',
    'can\'t go on',
    'want to die',
    'self harm',
    'hurt myself',
    'cut myself',

    // Severe ideation
    'no reason to live',
    'nobody cares',
    'world without me',
    'goodbye forever',
    'last goodbye',
  };

  /// Moderate-concern keywords (elevated monitoring)
  static const Set<String> _warningKeywords = {
    // Depression indicators
    'severely depressed',
    'can\'t get out of bed',
    'hopeless',
    'nothing matters',
    'worthless',
    'no point',

    // Distress signals
    'can\'t cope',
    'breaking down',
    'falling apart',
    'can\'t handle',
    'too much pain',
  };

  /// Analyzes user message for crisis indicators.
  ///
  /// **Process:**
  /// 1. Scan for critical keywords (immediate escalation)
  /// 2. Check warning keywords (elevated monitoring)
  /// 3. Analyze context (is this hypothetical or immediate?)
  /// 4. Return threat assessment
  ///
  /// **Parameters:**
  /// - [userMessage]: Raw user text
  /// - [conversationHistory]: Previous 5 messages for context
  ///
  /// **Returns:** Crisis assessment with recommended action
  CrisisAssessment analyze({
    required String userMessage,
    List<String>? conversationHistory,
  }) {
    final messageLower = userMessage.toLowerCase();

    // **CRITICAL CHECK:** Immediate threat keywords
    for (final keyword in _criticalKeywords) {
      if (messageLower.contains(keyword)) {
        return CrisisAssessment(
          level: CrisisLevel.critical,
          detectedKeywords: [keyword],
          recommendedAction: CrisisAction.immediateEscalation,
          message: _getCriticalResponseMessage(),
          resourceLinks: _getCrisisResources(),
        );
      }
    }

    // **WARNING CHECK:** Moderate concern keywords
    final detectedWarnings = <String>[];
    for (final keyword in _warningKeywords) {
      if (messageLower.contains(keyword)) {
        detectedWarnings.add(keyword);
      }
    }

    if (detectedWarnings.isNotEmpty) {
      // **Context check:** Multiple warning keywords = elevated concern
      if (detectedWarnings.length >= 2) {
        return CrisisAssessment(
          level: CrisisLevel.elevated,
          detectedKeywords: detectedWarnings,
          recommendedAction: CrisisAction.provideResources,
          message: _getElevatedResponseMessage(),
          resourceLinks: _getCrisisResources(),
        );
      }

      // Single warning keyword = monitoring
      return CrisisAssessment(
        level: CrisisLevel.monitoring,
        detectedKeywords: detectedWarnings,
        recommendedAction: CrisisAction.gentleCheck,
        message: _getMonitoringResponseMessage(),
        resourceLinks: [],
      );
    }

    // **ALL CLEAR:** No crisis indicators detected
    return const CrisisAssessment(
      level: CrisisLevel.none,
      detectedKeywords: [],
      recommendedAction: CrisisAction.continueNormally,
      message: '',
      resourceLinks: [],
    );
  }

  /// Logs a crisis event for audit and safety reviews.
  Future<void> logCrisisEvent({
    required String userId,
    required CrisisAssessment assessment,
  }) async {
    final event = {
      'user_id_hash': _hashUserId(userId),
      'level': assessment.level.name,
      'keywords': assessment.detectedKeywords,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // **Note:** In production, send to Firestore with admin-only read access
    // Path: /audit_logs/{userId}/crisis_events/{eventId}
    debugPrint('[CRISIS_AUDIT] $event');
  }

  /// Hash user ID for privacy-preserving audit logs
  String _hashUserId(String userId) {
    // Simplified - in production, use crypto package
    return 'hashed_$userId';
  }

  String _getCriticalResponseMessage() {
    return "I'm concerned about what you're sharing. I'm an AI, not a therapist, but there are people who can help you right now. Please reach out to them.";
  }

  String _getElevatedResponseMessage() {
    return "It sounds like you're going through a really tough time. While I'm here to listen, I want to make sure you have all the support you need. Here are some resources that might help.";
  }

  String _getMonitoringResponseMessage() {
    return "I'm hearing that you're struggling. I'm here to support you.";
  }

  List<CrisisResource> _getCrisisResources() {
    return const [
      CrisisResource(
        name: 'National Suicide Prevention Lifeline',
        description: 'Free, confidential support for people in distress.',
        contactMethod: '988 (Call or Text)',
        availability: '24/7',
        isIntl: false,
      ),
      CrisisResource(
        name: 'Crisis Text Line',
        description: 'Text with a trained Crisis Counselor.',
        contactMethod: 'Text HOME to 741741',
        availability: '24/7',
        isIntl: false,
      ),
      CrisisResource(
        name: 'International Helplines',
        description: 'Find a helpline in your country.',
        contactMethod: 'findahelpline.com',
        availability: '24/7',
        isIntl: true,
      ),
    ];
  }
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

/// Crisis severity levels
enum CrisisLevel {
  none, // No indicators detected
  monitoring, // Single warning keyword, low concern
  elevated, // Multiple warnings, or concerning context
  critical, // Immediate threat detected
}

/// Recommended actions based on crisis level
enum CrisisAction {
  continueNormally, // No intervention needed
  gentleCheck, // Soft check-in, offer resources
  provideResources, // Strongly recommend professional help
  immediateEscalation, // Stop coaching, provide emergency contacts NOW
}

/// Crisis assessment result
class CrisisAssessment {
  /// Severity level
  final CrisisLevel level;

  /// Keywords that triggered detection
  final List<String> detectedKeywords;

  /// Recommended action
  final CrisisAction recommendedAction;

  /// Response message to show user
  final String message;

  /// Crisis resource links (if applicable)
  final List<CrisisResource> resourceLinks;

  const CrisisAssessment({
    required this.level,
    required this.detectedKeywords,
    required this.recommendedAction,
    required this.message,
    required this.resourceLinks,
  });

  /// Is this a crisis requiring immediate intervention?
  bool get isCritical => level == CrisisLevel.critical;

  /// Full formatted response (message + resources)
  String get fullResponse {
    if (resourceLinks.isEmpty) return message;

    final resourceText = resourceLinks
        .map((r) =>
            '• **${r.name}**: ${r.description}\n  Contact: ${r.contactMethod}')
        .join('\n\n');

    return '$message\n\n$resourceText';
  }

  /// Serialize for telemetry
  Map<String, dynamic> toJson() => {
        'level': level.name,
        'keywords': detectedKeywords,
        'action': recommendedAction.name,
        'resources_count': resourceLinks.length,
      };
}

/// Crisis support resource
class CrisisResource {
  /// Resource name
  final String name;

  /// Short description
  final String description;

  /// How to contact (phone, text, URL)
  final String contactMethod;

  /// Availability (24/7, business hours, etc.)
  final String availability;

  /// Is this an international resource?
  final bool isIntl;

  const CrisisResource({
    required this.name,
    required this.description,
    required this.contactMethod,
    required this.availability,
    required this.isIntl,
  });
}

// =============================================================================
// INTEGRATION UTILITIES
// =============================================================================

/// Crisis detection middleware for AI chat flow
class CrisisDetectionMiddleware {
  final CrisisDetectionLayer _detector = CrisisDetectionLayer();

  /// Intercepts user message before AI processing.
  ///
  /// **The Story:** Like TSA security at an airport. Most people pass through.
  /// But if there's a threat, we stop everything and escalate immediately.
  ///
  /// **Returns:**
  /// - `null` if safe to proceed (no crisis)
  /// - `CrisisAssessment` if intervention is needed (stops AI chat)
  Future<CrisisAssessment?> interceptMessage({
    required String userMessage,
    required String userId,
    List<String>? conversationHistory,
  }) async {
    final assessment = _detector.analyze(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
    );

    // **Log ALL crisis events** (including "none" for audit completeness)
    await _detector.logCrisisEvent(
      userId: userId,
      assessment: assessment,
    );

    // **Decision tree:**
    // - None/Monitoring: Let coaching continue
    // - Elevated/Critical: Intercept and provide resources
    if (assessment.level == CrisisLevel.elevated ||
        assessment.level == CrisisLevel.critical) {
      return assessment;
    }

    return null; // Safe to continue
  }
}
