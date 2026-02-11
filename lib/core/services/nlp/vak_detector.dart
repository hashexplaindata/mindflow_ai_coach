
/// **VAK (Visual/Auditory/Kinesthetic) Detection Engine**
///
/// Every person has a primary representational system—the sense they use most
/// to process reality. Visual thinkers "see" the world. Auditory thinkers "hear"
/// it. Kinesthetic thinkers "feel" it.
///
/// **The Secret:** Match their system, and rapport skyrockets. Mismatch it,
/// and you're speaking different languages.
///
/// **The Story:** Imagine telling a visual person, "Feel the energy." They're
/// confused. Tell them "Picture this..." and their eyes light up. Same information,
/// different packaging.
///
/// **Use Cases:**
/// - Adapt AI coaching vocabulary to user's primary system
/// - Increase rapport scoring (PRD target: >0.85)
/// - Personalize focus induction scripts
/// - Customize motivational messaging
///
/// **Research:** Bandler & Grinder discovered this by studying master communicators.
/// Virginia Satir could "match" anyone instantly. This is her secret, systematized.
class VAKDetector {
  /// Detects primary representational system from text.
  ///
  /// **How It Works:**
  /// 1. Count sensory predicates (verbs, adjectives, metaphors)
  /// 2. Calculate percentages for V/A/K
  /// 3. Return dominant system + confidence
  ///
  /// **Requirements:** At least 50-100 words for accuracy
  ///
  /// **Parameters:**
  /// - [text]: User's written message(s)
  ///
  /// **Returns:** VAK profile with primary system and confidence
  VAKProfile detectFromText(String text) {
    final wordList = text.toLowerCase().split(RegExp(r'\s+'));

    int visualCount = 0;
    int auditoryCount = 0;
    int kinestheticCount = 0;

    // **Scan for sensory predicates**
    for (final word in wordList) {
      if (_visualPredicates.contains(word)) visualCount++;
      if (_auditoryPredicates.contains(word)) auditoryCount++;
      if (_kinestheticPredicates.contains(word)) kinestheticCount++;
    }

    final total = visualCount + auditoryCount + kinestheticCount;

    // **Edge case:** Not enough sensory language
    if (total < 3) {
      return VAKProfile(
        primarySystem: RepresentationalSystem.visual, // Default
        visualPercentage: 0.33,
        auditoryPercentage: 0.33,
        kinestheticPercentage: 0.33,
        confidence: 0.0, // Low confidence
        sampleSize: wordList.length,
      );
    }

    // **Calculate percentages**
    final visualPct = visualCount / total;
    final auditoryPct = auditoryCount / total;
    final kinestheticPct = kinestheticCount / total;

    // **Determine primary system** (highest percentage)
    RepresentationalSystem primary;
    double confidence;

    if (visualPct >= auditoryPct && visualPct >= kinestheticPct) {
      primary = RepresentationalSystem.visual;
      confidence = visualPct;
    } else if (auditoryPct >= visualPct && auditoryPct >= kinestheticPct) {
      primary = RepresentationalSystem.auditory;
      confidence = auditoryPct;
    } else {
      primary = RepresentationalSystem.kinesthetic;
      confidence = kinestheticPct;
    }

    return VAKProfile(
      primarySystem: primary,
      visualPercentage: visualPct,
      auditoryPercentage: auditoryPct,
      kinestheticPercentage: kinestheticPct,
      confidence: confidence,
      sampleSize: wordList.length,
    );
  }

  /// Adapts message to match user's VAK system.
  ///
  /// **The Magic:** Same core message, different sensory packaging.
  ///
  /// **Example:**
  /// Core: "Understand this concept"
  /// - Visual: "Picture this concept clearly"
  /// - Auditory: "Let me explain this concept"
  /// - Kinesthetic: "Grasp this concept firmly"
  ///
  /// **Parameters:**
  /// - [coreMessage]: The underlying meaning
  /// - [targetSystem]: User's primary VAK system
  ///
  /// **Returns:** Message rewritten in target system's language
  String adaptMessage({
    required String coreMessage,
    required RepresentationalSystem targetSystem,
  }) {
    // **Strategy:** Replace generic words with sensory-specific ones

    Map<String, String> replacements;

    switch (targetSystem) {
      case RepresentationalSystem.visual:
        replacements = _visualReplacements;
        break;
      case RepresentationalSystem.auditory:
        replacements = _auditoryReplacements;
        break;
      case RepresentationalSystem.kinesthetic:
        replacements = _kinestheticReplacements;
        break;
    }

    String adapted = coreMessage;

    // **Replace generic verbs with sensory-specific ones**
    replacements.forEach((generic, sensory) {
      adapted = adapted.replaceAll(
          RegExp(r'\b' + generic + r'\b', caseSensitive: false), sensory);
    });

    return adapted;
  }

  /// Generates focus induction script tailored to VAK system.
  ///
  /// **The Story:** A visual person needs to "see" focus. An auditory person
  /// needs to "hear" focus. A kinesthetic person needs to "feel" focus.
  ///
  /// **Same goal, different path.**
  String generateVAKFocusInduction(RepresentationalSystem system) {
    switch (system) {
      case RepresentationalSystem.visual:
        return _visualFocusInduction;
      case RepresentationalSystem.auditory:
        return _auditoryFocusInduction;
      case RepresentationalSystem.kinesthetic:
        return _kinestheticFocusInduction;
    }
  }

  // ===========================================================================
  // PREDICATE LIBRARIES (Word Lists for Each System)
  // ===========================================================================

  /// Visual predicates (seeing, looking, imagery)
  static final Set<String> _visualPredicates = {
    // Verbs
    'see', 'look', 'view', 'watch', 'observe', 'notice', 'appear', 'show',
    'reveal', 'picture', 'imagine', 'visualize', 'focus', 'glimpse', 'scan',
    'survey', 'clarify', 'illustrate', 'demonstrate', 'display', 'illuminate',
    'reflect', 'envision', 'glimpse', 'glance',
    // Adjectives
    'clear', 'bright', 'colorful', 'vivid', 'transparent', 'foggy', 'hazy',
    'distinct', 'visible', 'blurry', 'focused', 'sharp', 'dim', 'brilliant',
    // Phrases
    'looks like', 'appears to be', 'from my perspective', 'in view of',
    'shed light on', 'crystal clear', 'in the dark', 'birds eye view',
  };

  /// Auditory predicates (hearing, sound, tone)
  static final Set<String> _auditoryPredicates = {
    // Verbs
    'hear', 'listen', 'sound', 'tell', 'say', 'speak', 'talk', 'discuss',
    'mention', 'ask', 'ring', 'resonate', 'harmonize', 'tune', 'click',
    'whisper', 'shout', 'echo', 'amplify', 'voice', 'articulate', 'express',
    // Adjectives
    'loud', 'quiet', 'silent', 'noisy', 'clear', 'muted', 'harmonious',
    'dissonant', 'melodic', 'rhythmic', 'tonal',
    // Phrases
    'sounds like', 'rings a bell', 'tune in', 'tell myself', 'word for word',
    'loud and clear', 'unheard of', 'give me an earful',
  };

  /// Kinesthetic predicates (feeling, touching, doing)
  static final Set<String> _kinestheticPredicates = {
    // Verbs
    'feel', 'touch', 'grasp', 'hold', 'handle', 'move', 'push', 'pull',
    'press', 'lift', 'carry', 'grip', 'sense', 'experience', 'connect',
    'contact', 'impact', 'flow', 'solid', 'firm', 'warm', 'cold', 'smooth',
    'rough', 'heavy', 'light',
    // Adjectives
    'comfortable', 'uncomfortable', 'tense', 'relaxed', 'intense', 'gentle',
    'hard', 'soft', 'sharp', 'dull', 'heavy', 'light', 'solid', 'fluid',
    // Phrases
    'get in touch', 'hand in hand', 'get a hold of', 'slip through fingers',
    'come to grips', 'get a handle on', 'firm foundation', 'heated argument',
  };

  // ===========================================================================
  // REPLACEMENT MAPS (Generic → Sensory-Specific)
  // ===========================================================================

  static final Map<String, String> _visualReplacements = {
    'understand': 'see clearly',
    'know': 'realize',
    'think': 'picture',
    'remember': 'visualize',
    'learn': 'observe',
    'explain': 'illustrate',
    'aware': 'notice',
    'confused': 'unclear',
  };

  static final Map<String, String> _auditoryReplacements = {
    'understand': 'hear you',
    'know': 'sounds right',
    'think': 'tell myself',
    'remember': 'rings a bell',
    'learn': 'listen to',
    'explain': 'tell you',
    'aware': 'tune into',
    'confused': 'doesn\'t sound right',
  };

  static final Map<String, String> _kinestheticReplacements = {
    'understand': 'grasp',
    'know': 'feel confident',
    'think': 'sense that',
    'remember': 'get a feel for',
    'learn': 'get a handle on',
    'explain': 'walk you through',
    'aware': 'in touch with',
    'confused': 'feels off',
  };

  // ===========================================================================
  // VAK-SPECIFIC FOCUS INDUCTIONS
  // ===========================================================================

  static const String _visualFocusInduction = '''
Picture yourself in a space of complete clarity. See the task before you, 
sharp and well-defined. Notice how distractions blur into the background, 
like fog lifting. Your vision narrows to what matters most. The clearer you 
see it, the more focused you become. Imagine that focus as a spotlight, 
illuminating only what serves you right now.
''';

  static const String _auditoryFocusInduction = '''
Listen to the rhythm of your breathing. Hear how it slows, steadies, becomes 
the metronome of focus. External noise fades to background static. Your 
internal voice speaks clearly: "This is what matters now." Tune into that 
voice. Let it guide you. The words become actions, and the actions flow in 
perfect harmony with your intention.
''';

  static const String _kinestheticFocusInduction = '''
Feel your body settling into this moment. Sense the weight of your device, 
the contact with your chair. As you ground into these physical sensations, 
mental tension releases. You're becoming solid, present, immovable in your 
intention. The work isn't a burden—it's movement, flow, energy directed. 
Get a handle on this feeling. Hold onto it. Let it carry you forward.
''';
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

/// Primary representational system (how person processes reality)
enum RepresentationalSystem {
  visual, // Processes through imagery
  auditory, // Processes through sound
  kinesthetic, // Processes through feeling/doing
}

/// VAK profile detected from user's language
class VAKProfile {
  /// Dominant system
  final RepresentationalSystem primarySystem;

  /// Visual percentage (0.0-1.0)
  final double visualPercentage;

  /// Auditory percentage (0.0-1.0)
  final double auditoryPercentage;

  /// Kinesthetic percentage (0.0-1.0)
  final double kinestheticPercentage;

  /// Confidence in detection (0.0-1.0)
  /// Higher = more sensory language detected, stronger signal
  final double confidence;

  /// Number of words analyzed
  final int sampleSize;

  const VAKProfile({
    required this.primarySystem,
    required this.visualPercentage,
    required this.auditoryPercentage,
    required this.kinestheticPercentage,
    required this.confidence,
    required this.sampleSize,
  });

  /// Is detection reliable? (confidence > 0.5 && sample >=100 words)
  bool get isReliable => confidence > 0.5 && sampleSize >= 100;

  /// Human-readable description
  String get description {
    final systemName = primarySystem.name.toUpperCase();
    final pct = (confidence * 100).toStringAsFixed(0);
    return '$systemName-dominant ($pct% confidence)';
  }

  /// Serialize for telemetry
  Map<String, dynamic> toJson() => {
        'primary_system': primarySystem.name,
        'visual_pct': visualPercentage,
        'auditory_pct': auditoryPercentage,
        'kinesthetic_pct': kinestheticPercentage,
        'confidence': confidence,
        'sample_size': sampleSize,
        'is_reliable': isReliable,
      };
}

// =============================================================================
// VAK ADAPTATION EXAMPLES
// =============================================================================

/// Example adaptations for common coaching scenarios
class VAKAdaptationExamples {
  /// Goal setting adaptations
  static const Map<RepresentationalSystem, String> goalSetting = {
    RepresentationalSystem.visual:
        'Envision your ideal future. What does success look like? Paint a clear picture.',
    RepresentationalSystem.auditory:
        'Describe your ideal future. What does success sound like? Tell me the story.',
    RepresentationalSystem.kinesthetic:
        'Feel into your ideal future. What does success feel like? Sense the experience.',
  };

  /// Motivation adaptations
  static const Map<RepresentationalSystem, String> motivation = {
    RepresentationalSystem.visual:
        'See yourself completing this. Notice how bright the finish line appears.',
    RepresentationalSystem.auditory:
        'Hear the voice of your future self celebrating this achievement.',
    RepresentationalSystem.kinesthetic:
        'Feel the satisfaction of accomplishment. Let that energy pull you forward.',
  };

  /// Stress reduction adaptations
  static const Map<RepresentationalSystem, String> stressReduction = {
    RepresentationalSystem.visual:
        'Picture tension as a color. Watch it fade to white, then disappear completely.',
    RepresentationalSystem.auditory:
        'Listen to stress dissolving. Like noise fading to silence, then peace.',
    RepresentationalSystem.kinesthetic:
        'Feel tension as temperature. Sense it cooling, mellowing, releasing from your body.',
  };
}
