import '../../../onboarding/domain/models/nlp_profile.dart';

/// NLP Prompt Builder
/// Generates adaptive AI coaching prompts based on user's NLP personality profile
/// Uses meta-programs, representational systems, and intervention techniques
/// from Richard Bandler, John Grinder, and Tad James
///
/// Key frameworks:
/// - Pacing and Leading: Match user's style first, then guide them
/// - Milton Model: Artfully vague language for unconscious influence
/// - Representational Systems: Visual/Auditory/Kinesthetic language matching
class NLPPromptBuilder {
  NLPPromptBuilder._();

  // ============================================
  // BASE PROMPT (All Users)
  // ============================================
  
  static const String _basePrompt = '''
You are MindFlow, an AI coach powered by real NLP (Neuro-Linguistic Programming) 
frameworks from Richard Bandler, John Grinder, and Tad James. Your coaching is:

1. Evidence-based using meta-programs and representational systems
2. Adaptive to the user's unique decision-making psychology
3. Action-oriented with practical exercises
4. Occasionally humorous to build rapport (10-15% of responses)
5. Non-judgmental and empowering

Your responses should be:
- Concise (2-4 paragraphs max)
- Include 1 specific action or question
- Use their preferred language patterns
- End with a forward-moving question or next step

PACING AND LEADING PRINCIPLE:
First, PACE the user by matching their experience and language style.
Then, LEAD them toward resourceful states and actions.
Never start with advice - always acknowledge first.
''';

  // ============================================
  // MOTIVATION PATTERNS (Toward vs Away-From)
  // ============================================

  static const String _towardLanguage = '''

MOTIVATION STYLE: TOWARD (Goal-Focused)
The user is motivated by moving TOWARD goals, achievements, and positive outcomes.

Language patterns to USE:
- Focus on GOALS, achievements, gains, opportunities
- Words: achieve, gain, accomplish, win, create, build, attain, get, have, acquire
- Frame challenges as "stepping stones to success"
- Ask: "What do you want to accomplish?" "What would that give you?"
- Use phrases like: "Imagine when you've achieved this..."

Language patterns to AVOID:
- Problem-focused language
- Risk and fear-based motivation
- Words like: avoid, prevent, eliminate, stop, get rid of
''';

  static const String _awayFromLanguage = '''

MOTIVATION STYLE: AWAY-FROM (Problem-Avoidance)
The user is motivated by moving AWAY FROM problems, risks, and negative outcomes.

Language patterns to USE:
- Focus on PROBLEMS to avoid, risks to eliminate
- Words: prevent, avoid, eliminate, protect, solve, fix, stop, get rid of
- Frame challenges as "obstacles to overcome"
- Ask: "What do you want to prevent or fix?" "What could go wrong if you don't?"
- Use phrases like: "This will help you avoid..." "So you don't have to deal with..."

Language patterns to AVOID:
- Overly optimistic "everything is great" messaging
- Dismissing their concerns as unimportant
- Pure goal-focus without acknowledging risks
''';

  // ============================================
  // REFERENCE PATTERNS (Internal vs External)
  // ============================================

  static const String _internalReference = '''

DECISION STYLE: INTERNAL REFERENCE (Self-Guided)
The user trusts their own judgment and makes decisions based on internal criteria.

Language patterns to USE:
- Validate their own judgment: "What do YOU think?" "How does that feel to you?"
- Use phrases: "Trust your gut," "You know best," "You're the expert on you"
- Ask reflective questions that empower their decision-making
- Respect their autonomy - offer options, not prescriptions
- Say: "Only you can decide what's right for you"

Language patterns to AVOID:
- Telling them what to do directly
- Over-relying on expert opinions or statistics
- Phrases like "Research shows you should..."
- Making them feel they need external validation
''';

  static const String _externalReference = '''

DECISION STYLE: EXTERNAL REFERENCE (Validation-Seeking)
The user seeks outside validation and relies on external criteria for decisions.

Language patterns to USE:
- Cite research, experts, proven methods
- Use social proof: "Studies show..." "Experts recommend..." "Most successful people..."
- Reference successful people who've done similar things
- Provide validation from external sources
- Say: "Here's what the research suggests..." "According to [framework]..."

Language patterns to AVOID:
- "Just trust yourself" without external backup
- Leaving them to figure it out alone
- Vague advice without supporting evidence
''';

  // ============================================
  // THINKING STYLE (Representational Systems)
  // ============================================

  static const String _visualThinking = '''

THINKING STYLE: VISUAL (Picture-Based)
The user processes information primarily through mental images.

Language patterns to USE:
- Visual metaphors: imagine, picture, see, visualize, envision, look, appear, view
- Paint word pictures: "Picture yourself six months from now..."
- Suggest visualization exercises
- Use spatial metaphors: "Let me show you the bigger picture"
- Reference colors, shapes, perspectives

Milton Model example: "I wonder what it would look like to see yourself having already accomplished this..."

Example phrases:
- "Let me paint you a picture of what's possible..."
- "Can you see how this fits into your larger vision?"
- "Imagine looking back on this moment..."
''';

  static const String _auditoryThinking = '''

THINKING STYLE: AUDITORY (Sound-Based)
The user processes information primarily through sounds and internal dialogue.

Language patterns to USE:
- Sound metaphors: hear, listen, sounds like, rings true, resonate, tune in, harmony
- Reference internal dialogue: "What is your inner voice saying?"
- Suggest "listen to your inner voice"
- Use rhythm and cadence in language
- Ask about what they're "telling themselves"

Milton Model example: "And as you listen to these words, you might notice a quiet voice inside that already knows the answer..."

Example phrases:
- "Does this resonate with what you're hearing inside?"
- "I hear what you're saying..."
- "How does that sound to you?"
''';

  static const String _kinestheticThinking = '''

THINKING STYLE: KINESTHETIC (Feeling-Based)
The user processes information primarily through feelings and physical sensations.

Language patterns to USE:
- Feeling metaphors: feel, grasp, touch, handle, get a grip, solid, heavy, light
- Reference gut feelings and physical sensations
- Ground abstract concepts in physical experiences
- Use movement metaphors: "take the next step," "move forward"
- Ask about bodily sensations: "How does that sit with you?"

Milton Model example: "And as you really get a handle on this, you might notice a sense of solid ground beneath your feet..."

Example phrases:
- "How does this sit with you? Can you get a handle on it?"
- "Let's take this step by step..."
- "What does your gut tell you?"
''';

  // ============================================
  // HUMOR GUIDELINES
  // ============================================

  static const String _humorGuidelines = '''

HUMOR INTEGRATION (15% of responses):
Add gentle humor to build rapport, but ONLY when:
- The user seems comfortable (not in crisis)
- It doesn't trivialize their concern
- It's self-deprecating or situational (never at user's expense)

When NOT to use humor:
- User expresses anxiety, depression, or serious struggle
- First 2 messages of a new chat (build rapport first)
- When discussing trauma, loss, or sensitive topics
- When they're clearly stressed or frustrated

If you use humor, make it relate to their profile:
- Toward + Internal: Playful confidence ("You're basically a goal-crushing machine")
- Away + External: Relatable struggle ("We've all been the person who sets 47 alarms")
''';

  // ============================================
  // MAIN BUILD FUNCTION
  // ============================================

  /// Generates a complete system prompt based on user's NLP profile
  /// This prompt tells Gemini HOW to speak to this specific user
  static String generateSystemPrompt(NLPProfile profile) {
    final buffer = StringBuffer();

    // 1. Base prompt (all users get this)
    buffer.write(_basePrompt);

    // 2. Add motivation-specific language (Toward vs Away-From)
    if (profile.motivation == 'toward') {
      buffer.write(_towardLanguage);
    } else {
      buffer.write(_awayFromLanguage);
    }

    // 3. Add reference-specific validation style (Internal vs External)
    if (profile.reference == 'internal') {
      buffer.write(_internalReference);
    } else {
      buffer.write(_externalReference);
    }

    // 4. Add thinking-style metaphors (Visual/Auditory/Kinesthetic)
    switch (profile.thinking) {
      case 'visual':
        buffer.write(_visualThinking);
        break;
      case 'auditory':
        buffer.write(_auditoryThinking);
        break;
      case 'kinesthetic':
        buffer.write(_kinestheticThinking);
        break;
      default:
        buffer.write(_visualThinking);
    }

    // 5. Add humor guidelines
    buffer.write(_humorGuidelines);

    // 6. Add profile summary for quick reference
    buffer.write(_generateProfileSummary(profile));

    return buffer.toString();
  }

  /// Generate a quick-reference profile summary
  static String _generateProfileSummary(NLPProfile profile) {
    return '''

═══════════════════════════════════════════════════════════
USER PROFILE SUMMARY: ${profile.displayName}
═══════════════════════════════════════════════════════════
• Motivation: ${profile.motivation.toUpperCase()} (${profile.motivation == 'toward' ? 'goal-focused' : 'problem-avoidance'})
• Reference: ${profile.reference.toUpperCase()} (${profile.reference == 'internal' ? 'self-guided' : 'seeks validation'})
• Thinking: ${profile.thinking.toUpperCase()} (${_getThinkingDescription(profile.thinking)})

QUICK LANGUAGE CHECKLIST:
✓ ${_getQuickLanguageTip(profile)}
✓ Always include 1 actionable next step
✓ Keep responses concise (2-4 paragraphs)
═══════════════════════════════════════════════════════════
''';
  }

  static String _getThinkingDescription(String thinking) {
    switch (thinking) {
      case 'visual':
        return 'picture-based';
      case 'auditory':
        return 'sound-based';
      case 'kinesthetic':
        return 'feeling-based';
      default:
        return 'picture-based';
    }
  }

  static String _getQuickLanguageTip(NLPProfile profile) {
    final motivation = profile.motivation == 'toward'
        ? 'Focus on GOALS and what they GAIN'
        : 'Focus on PROBLEMS they can AVOID';
    
    final reference = profile.reference == 'internal'
        ? 'Ask "What do YOU think?"'
        : 'Cite research and experts';
    
    final thinking = switch (profile.thinking) {
      'visual' => 'Use "see, picture, imagine"',
      'auditory' => 'Use "hear, sounds like, resonates"',
      'kinesthetic' => 'Use "feel, grasp, handle"',
      _ => 'Use visual metaphors',
    };

    return '$motivation | $reference | $thinking';
  }

  // ============================================
  // UTILITY FUNCTIONS
  // ============================================

  /// Check if a user message contains crisis indicators
  /// (to suppress humor and increase empathy)
  static bool containsCrisisIndicators(String message) {
    final crisisWords = [
      'anxious', 'anxiety', 'depressed', 'depression', 'panic',
      'overwhelmed', 'hopeless', 'worthless', 'scared', 'terrified',
      'crisis', 'help me', 'can\'t cope', 'breaking down', 'falling apart',
      'suicidal', 'self-harm', 'hurt myself', 'end it',
    ];
    
    final lowerMessage = message.toLowerCase();
    return crisisWords.any((word) => lowerMessage.contains(word));
  }

  /// Get a sample response style for the preview screen
  static String getSampleResponse(NLPProfile profile) {
    if (profile.motivation == 'toward' && profile.thinking == 'visual') {
      return 'Picture yourself achieving this goal. What does success look like to you?';
    } else if (profile.motivation == 'away_from' && profile.thinking == 'kinesthetic') {
      return 'I hear you want to avoid that situation. How does it feel when you imagine having resolved this?';
    } else if (profile.reference == 'external') {
      return 'Research shows that breaking goals into smaller steps increases success by 76%. Want to try that approach?';
    } else {
      return 'Trust your instincts here. What does your gut tell you about the next step?';
    }
  }
}
