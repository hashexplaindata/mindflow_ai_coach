/// **Meta-Model Precision Questioning Engine**
///
/// The Meta-Model is the surgical knife of language. Where the Milton Model
/// is artfully vague (to bypass resistance), the Meta-Model is laser-precise
/// (to expose and shatter limiting beliefs).
///
/// **The Story:** Imagine someone says, "I can't focus." The Meta-Model asks:
/// "Can't focus on what, specifically? Never? What stops you?" These questions
/// force the mind to examine the belief structure and find the holes.
///
/// **Origin:** Developed by Bandler & Grinder from studying Virginia Satir's
/// family therapy genius. They reverse-engineered HOW she transformed clients.
///
/// **Use Cases:**
/// - Breaking "stuck" loops
/// - Exposing procrastination logic
/// - Challenging perfectionism
/// - Clarifying vague goals
///
/// **Warning:** This is confrontational (gently). Use only when user is receptive.
class MetaModelEngine {
  /// Challenges unspecified verbs.
  ///
  /// **Pattern:** User says vague action without details.
  /// **Examples:**
  /// - "I procrastinate" → "How, specifically, do you procrastinate?"
  /// - "I fail" → "Fail at what, exactly? How do you measure failure?"
  /// - "I'm stuck" → "Stuck doing what? What would 'unstuck' look like?"
  ///
  /// **Why It Works:** Vagueness protects the limiting belief. Specificity kills it.
  String challengeUnspecifiedVerb(String statement) {
    final verbPatterns = {
      'procrastinate':
          'How, specifically, do you procrastinate? What does that look like?',
      'fail': 'Fail at what, exactly? What would success look like?',
      'stuck': 'Stuck where? What would movement look like?',
      'struggle': 'Struggle with what, specifically? What part is hardest?',
      'can\'t focus': 'Can\'t focus on what? For how long? In what context?',
      'overwhelmed':
          'Overwhelmed by what, specifically? What\'s the first thing?',
    };

    for (final pattern in verbPatterns.keys) {
      if (statement.toLowerCase().contains(pattern)) {
        return verbPatterns[pattern]!;
      }
    }

    // Generic fallback
    return 'Can you be more specific about what that means?';
  }

  /// Challenges nominalizations.
  ///
  /// **Nominalizations:** Process words disguised as things.
  /// **Examples:**
  /// - "My anxiety is stopping me" → "Who is anxious? About what? When?"
  /// - "The stress is too much" → "What specifically is stressing you?"
  /// - "I lack motivation" → "What would motivate you? What's motivating about it?"
  ///
  /// **The Trick:** "Anxiety" isn't a thing—it's you feeling anxious. Turning
  /// processes into objects makes them seem permanent and external. Reversing
  /// this returns agency to the user.
  String challengeNominalization(String statement) {
    final nominalizationPatterns = {
      'anxiety':
          'Who is anxious? About what, specifically? When does this anxious feeling arise?',
      'stress':
          'What specifically is stressing you? What would it take to reduce that?',
      'motivation':
          'What would motivate you? What has motivated you in the past?',
      'confusion': 'Confused about what? What would clarity look like?',
      'frustration':
          'What specifically frustrates you? What would satisfaction feel like?',
      'resistance':
          'Resisting what? What if you stopped resisting—what would happen?',
      'fear':
          'Fear of what, specifically? What\'s the worst that could happen? The best?',
    };

    for (final pattern in nominalizationPatterns.keys) {
      if (statement.toLowerCase().contains(pattern)) {
        return nominalizationPatterns[pattern]!;
      }
    }

    return 'What specifically does that mean? Can you turn that into an action?';
  }

  /// Challenges modal operators (rules/limitations).
  ///
  /// **Modal Operators:** "Must," "should," "can't," "have to."
  /// These words reveal rules the person treats as unbreakable laws of nature.
  ///
  /// **Examples:**
  /// - "I can't start until I'm ready" → "What would happen if you started unprepared?"
  /// - "I must be perfect" → "Who says? What if good enough is actually better?"
  /// - "I should know this" → "Says who? What if not knowing is the first step?"
  ///
  /// **The Reveal:** Most "musts" are self-imposed prisons. The question reveals
  /// the door was never locked.
  String challengeModalOperator(String statement) {
    // Modal operators of necessity (must, should, have to)
    if (statement.contains(
        RegExp(r'\b(must|should|have to|need to)\b', caseSensitive: false))) {
      return 'Says who? What would happen if you didn\'t? What if that rule doesn\'t apply here?';
    }

    // Modal operators of impossibility (can't, unable to, impossible)
    if (statement.contains(RegExp(r"\b(can't|cannot|unable to|impossible)\b",
        caseSensitive: false))) {
      return 'What stops you? What would happen if you could? Ever been a time you did?';
    }

    return 'What rule are you following? Is it serving you?';
  }

  /// Challenges universal quantifiers (always, never, everyone, no one).
  ///
  /// **Universal Quantifiers:** Absolutes that are almost always false.
  /// **Examples:**
  /// - "I always procrastinate" → "Always? Never done anything on time?"
  /// - "I never finish" → "Never? Not even once?"
  /// - "Everyone is better than me" → "Everyone? Every single person? Even beginners?"
  ///
  /// **The Crack:** One counterexample breaks the generalization. And there's
  /// ALWAYS a counterexample.
  String challengeUniversalQuantifier(String statement) {
    final quantifierPatterns = {
      'always': 'Always? Every single time? Never an exception?',
      'never': 'Never? Not even once? Under no circumstances?',
      'everyone': 'Everyone? Every single person without exception?',
      'no one': 'No one? Not a single person? Absolutely nobody?',
      'all': 'All of them? No exceptions whatsoever?',
      'none': 'None? Not even one?',
    };

    for (final pattern in quantifierPatterns.keys) {
      if (statement.toLowerCase().contains(pattern)) {
        return quantifierPatterns[pattern]!;
      }
    }

    return 'Is that really true 100% of the time? Can you think of even one exception?';
  }

  /// Challenges mind reading (assuming what others think).
  ///
  /// **Mind Reading:** "They think I'm incompetent." "He doesn't respect me."
  /// **Challenge:** "How do you know? What evidence supports that? What if you're wrong?"
  ///
  /// **The Reality:** Most mind reading is projection. We see our fears reflected.
  String challengeMindReading(String statement) {
    if (statement.contains(RegExp(
        r'\b(they think|he thinks|she thinks|people think|others think)\b',
        caseSensitive: false))) {
      return 'How do you know what they think? What actual evidence supports that? What if you asked them?';
    }

    return 'Are you reading minds, or projecting? What do you actually know vs. assume?';
  }

  /// Generates complete Meta-Model intervention.
  ///
  /// **Use Case:** User makes limiting statement. We systematically dismantle it.
  ///
  /// **Process:**
  /// 1. Identify the language pattern
  /// 2. Ask precision question
  /// 3. Wait for answer (reveals the crack in the belief)
  /// 4. Expand the crack with follow-up
  ///
  /// **Example:**
  /// User: "I can't focus because I'm too anxious."
  /// Meta-Model: Unspecified verb ("focus on what?") + Nominalization ("who is anxious?")
  MetaModelIntervention analyzeStatement(String statement) {
    final patterns = <LanguagePattern>[];
    final questions = <String>[];

    // Check for unspecified verbs
    if (RegExp(r'\b(procrastinate|fail|stuck|struggle)\b', caseSensitive: false)
        .hasMatch(statement)) {
      patterns.add(LanguagePattern.unspecifiedVerb);
      questions.add(challengeUnspecifiedVerb(statement));
    }

    // Check for nominalizations
    if (RegExp(r'\b(anxiety|stress|motivation|confusion|fear)\b',
            caseSensitive: false)
        .hasMatch(statement)) {
      patterns.add(LanguagePattern.nominalization);
      questions.add(challengeNominalization(statement));
    }

    // Check for modal operators
    if (RegExp(r"\b(can't|must|should|have to|unable)\b", caseSensitive: false)
        .hasMatch(statement)) {
      patterns.add(LanguagePattern.modalOperator);
      questions.add(challengeModalOperator(statement));
    }

    // Check for universal quantifiers
    if (RegExp(r'\b(always|never|everyone|no one|all|none)\b',
            caseSensitive: false)
        .hasMatch(statement)) {
      patterns.add(LanguagePattern.universalQuantifier);
      questions.add(challengeUniversalQuantifier(statement));
    }

    // Check for mind reading
    if (RegExp(r'\b(think|thinks|believes)\b', caseSensitive: false)
        .hasMatch(statement)) {
      patterns.add(LanguagePattern.mindReading);
      questions.add(challengeMindReading(statement));
    }

    return MetaModelIntervention(
      originalStatement: statement,
      detectedPatterns: patterns,
      precisionQuestions: questions,
    );
  }
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

/// Language patterns detected by Meta-Model
enum LanguagePattern {
  unspecifiedVerb, // Vague actions
  nominalization, // Process → thing
  modalOperator, // Must/can't/should
  universalQuantifier, // Always/never/everyone
  mindReading, // Assuming others' thoughts
  causeAndEffect, // X causes Y (often false)
  complexEquivalence, // X means Y (often faulty logic)
}

/// Meta-Model analysis and intervention
class MetaModelIntervention {
  /// Original limiting statement
  final String originalStatement;

  /// Language patterns detected
  final List<LanguagePattern> detectedPatterns;

  /// Precision questions to challenge belief
  final List<String> precisionQuestions;

  const MetaModelIntervention({
    required this.originalStatement,
    required this.detectedPatterns,
    required this.precisionQuestions,
  });

  /// Primary question (most impactful)
  String get primaryQuestion => precisionQuestions.isNotEmpty
      ? precisionQuestions.first
      : 'Can you say more about that?';

  /// All questions combined for comprehensive challenge
  String get fullIntervention => precisionQuestions.join('\n\n');

  /// Serialize for telemetry
  Map<String, dynamic> toJson() => {
        'original_statement': originalStatement,
        'patterns': detectedPatterns.map((p) => p.name).toList(),
        'questions': precisionQuestions,
      };
}

// =============================================================================
// META-MODEL LIBRARY (Common Interventions)
// =============================================================================

/// Pre-built Meta-Model interventions for common limiting beliefs
class MetaModelLibrary {
  /// Procrastination interventions
  static const Map<String, String> procrastinationChallenges = {
    'I procrastinate too much':
        'How specifically do you procrastinate? On what tasks? At what times? What are you doing instead?',
    'I can\'t start until I\'m ready':
        'What would "ready" look like? What if being ready requires starting? What if you started unprepared—what\'s the worst that happens?',
    'I always put things off':
        'Always? Every single thing? Can you recall even one time you didn\'t? What was different then?',
  };

  /// Perfectionism interventions
  static const Map<String, String> perfectionismChallenges = {
    'It needs to be perfect':
        'Says who? Perfect according to what standard? What if good enough is actually better? What would 80% look like?',
    'I can\'t accept mistakes':
        'What happens if you make a mistake? The worst case? Has that ever actually happened? What did you learn from past mistakes?',
    'Everyone expects perfection':
        'Everyone? Have you asked them? What if they prefer done over perfect? What if perfectionism is holding you back?',
  };

  /// Imposter syndrome interventions
  static const Map<String, String> imposterChallenges = {
    'I don\'t belong here':
        'What evidence shows you don\'t belong? What evidence shows you DO? Who decided you don\'t? What if you\'re wrong?',
    'Everyone is better than me':
        'Everyone? Every single person? Even those who started after you? What are you better at than others?',
    'I\'m a fraud':
        'A fraud in what way? What would a "real" one look like? If you were a fraud, would you be this concerned about being one?',
  };

  /// Anxiety interventions
  static const Map<String, String> anxietyChallenges = {
    'I\'m too anxious':
        'Anxious about what, specifically? When? Where? What if that anxiety is just energy that needs directing?',
    'Anxiety stops me':
        'How does it stop you? What action specifically can\'t you take? Have you ever acted despite anxiety? What happened?',
    'I can\'t handle it':
        'Can\'t handle what? What would "handling it" look like? What if you\'ve been handling it all along?',
  };
}
