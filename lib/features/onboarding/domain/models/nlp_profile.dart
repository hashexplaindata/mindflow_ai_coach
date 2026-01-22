/// NLP Profile Model
/// Represents a user's psychological decision-making patterns
/// Based on Tad James meta-programs and Bandler/Grinder representational systems
class NLPProfile {
  const NLPProfile({
    required this.motivation,
    required this.reference,
    required this.thinking,
    this.processing = 'options',
    this.change = 'sameness',
  });

  /// Motivation direction: toward goals OR away from problems
  /// "Toward" users: Focus on achievements, gains, opportunities
  /// "Away-From" users: Focus on avoiding problems, eliminating risks
  final String motivation; // 'toward' | 'away_from'

  /// Decision reference: internal validation OR external validation
  /// "Internal": Trust their own judgment, self-guided
  /// "External": Seek outside validation, rely on experts/research
  final String reference; // 'internal' | 'external'

  /// Primary thinking style (representational system)
  /// "Visual": Thinks in images, uses visual metaphors
  /// "Auditory": Thinks in sounds, uses auditory metaphors  
  /// "Kinesthetic": Thinks in feelings, uses touch/movement metaphors
  final String thinking; // 'visual' | 'auditory' | 'kinesthetic'

  /// Processing preference
  /// "Options": Creative exploration, likes choices
  /// "Procedures": Prefers proven step-by-step processes
  final String processing; // 'options' | 'procedures'

  /// Change tolerance
  /// "Sameness": Prefers stability, routines
  /// "Difference": Seeks novelty, variety
  final String change; // 'sameness' | 'difference'

  /// Generate a friendly display name for the profile
  String get displayName {
    final typeNames = {
      'toward_visual_internal': 'The Visionary Achiever',
      'toward_visual_external': 'The Inspired Leader',
      'toward_auditory_internal': 'The Strategic Thinker',
      'toward_auditory_external': 'The Collaborative Innovator',
      'toward_kinesthetic_internal': 'The Intuitive Doer',
      'toward_kinesthetic_external': 'The Empathic Builder',
      'away_from_visual_internal': 'The Careful Planner',
      'away_from_visual_external': 'The Risk Analyst',
      'away_from_auditory_internal': 'The Critical Evaluator',
      'away_from_auditory_external': 'The Safety Researcher',
      'away_from_kinesthetic_internal': 'The Protective Guardian',
      'away_from_kinesthetic_external': 'The Cautious Navigator',
    };

    final key = '${motivation}_${thinking}_$reference';
    return typeNames[key] ?? 'The Mindful Explorer';
  }

  /// Get emoji representation
  String get emoji {
    switch (thinking) {
      case 'visual':
        return '👁️';
      case 'auditory':
        return '👂';
      case 'kinesthetic':
        return '✋';
      default:
        return '🧠';
    }
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'motivation': motivation,
      'reference': reference,
      'thinking': thinking,
      'processing': processing,
      'change': change,
    };
  }

  /// Create from Firestore Map
  factory NLPProfile.fromMap(Map<String, dynamic> map) {
    return NLPProfile(
      motivation: map['motivation'] ?? 'toward',
      reference: map['reference'] ?? 'internal',
      thinking: map['thinking'] ?? 'visual',
      processing: map['processing'] ?? 'options',
      change: map['change'] ?? 'sameness',
    );
  }

  /// Default profile for new users (before profiling)
  static const NLPProfile defaultProfile = NLPProfile(
    motivation: 'toward',
    reference: 'internal',
    thinking: 'visual',
  );

  /// Copy with modifications
  NLPProfile copyWith({
    String? motivation,
    String? reference,
    String? thinking,
    String? processing,
    String? change,
  }) {
    return NLPProfile(
      motivation: motivation ?? this.motivation,
      reference: reference ?? this.reference,
      thinking: thinking ?? this.thinking,
      processing: processing ?? this.processing,
      change: change ?? this.change,
    );
  }

  @override
  String toString() {
    return 'NLPProfile(motivation: $motivation, reference: $reference, '
        'thinking: $thinking, processing: $processing, change: $change)';
  }
}
