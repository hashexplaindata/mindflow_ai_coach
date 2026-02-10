import 'dart:math';

/// **Milton Model Linguistic Engine**
///
/// Named after Milton Erickson, the father of modern hypnotherapy, this engine
/// generates indirect suggestion patterns that bypass conscious resistance and
/// create cognitive shifts at the unconscious level.
///
/// **The Story:** Imagine planting ideas without triggering defenses. Like a master
/// storyteller who makes you believe the message was YOUR idea all along.
///
/// **Ethics Disclosure per Constitution:** All Milton Model patterns must be disclosed
/// during onboarding as "Cognitive Reframing Tools." Transparency is non-negotiable.
///
/// **Use Cases:**
/// - Focus induction ("As you sit there, your mind naturally filters...")
/// - Motivation calibration ("You can start now, or in a moment...")
/// - Pattern interrupts for procrastination loops
/// - Stress reduction through linguistic pacing
///
/// **Agent Rules Compliance:** All user-facing strings use these patterns.
class MiltonModelEngine {
  final Random _random = Random();

  /// Generates presupposition patterns.
  ///
  /// **Presuppositions:** Linguistic structures that assume something to be true.
  /// Rather than commanding "Focus!", we presuppose they're ALREADY focusing.
  ///
  /// **The Magic:** The conscious mind argues with commands but accepts presuppositions.
  ///
  /// **Examples:**
  /// - "As you notice your breathing slowing..." (presupposes breathing IS slowing)
  /// - "When you find yourself in flow..." (presupposes flow WILL happen)
  /// - "Before you complete this task..." (presupposes task WILL be completed)
  ///
  /// **Parameters:**
  /// - [action]: The desired state/behavior ("focusing", "entering flow", "feeling calm")
  /// - [timeFrame]: when/as/before/after/while
  ///
  /// **Returns:** Hypnotic presupposition sentence
  String generatePresupposition({
    required String action,
    TimeFrame? timeFrame,
  }) {
    final frame = timeFrame ?? _randomTimeFrame();

    final templates = {
      TimeFrame.as_: [
        'As you $action, you may notice other distractions fading away.',
        'As you continue $action, your mind naturally optimizes for this state.',
        'As you find yourself $action, everything else becomes secondary.',
      ],
      TimeFrame.when: [
        'When you begin $action, the resistance dissolves on its own.',
        'When you notice yourself $action, trust that momentum.',
        'When you realize you\'re $action, the work is already flowing.',
      ],
      TimeFrame.before: [
        'Before you even fully recognize it, you\'ll be $action.',
        'Before this session ends, you\'ll have been $action for longer than expected.',
        'Before you think about it too much, you\'ll find yourself $action.',
      ],
      TimeFrame.after: [
        'After you begin $action, everything becomes easier.',
        'After just a moment of $action, you\'ll wonder why you hesitated.',
        'After $action for even a short time, the momentum carries you forward.',
      ],
      TimeFrame.while_: [
        'While you\'re $action, your unconscious mind handles the details.',
        'While you continue $action, time seems to flow differently.',
        'While you\'re $action, notice how natural it feels.',
      ],
    };

    final options = templates[frame]!;
    return options[_random.nextInt(options.length)];
  }

  /// Generates embedded commands.
  ///
  /// **Embedded Commands:** Direct instructions hidden within larger sentences.
  /// The conscious mind hears the sentence, the unconscious hears the command.
  ///
  /// **The Secret:** Mark commands with subtle emphasis (caps in text, vocal
  /// tonality in speech). The unconscious notices.
  ///
  /// **Examples:**
  /// - "I wonder if you can BEGIN TO FILTER unnecessary thoughts."
  /// - "Many people find it easy to ENTER FLOW when ready."
  /// - "You don't need to FOCUS COMPLETELY until you're prepared."
  ///
  /// **Parameters:**
  /// - [command]: The directive ("focus", "relax", "begin", "release")
  /// - [target]: What to do it to (optional, e.g., "distractions", "tension")
  ///
  /// **Returns:** Sentence with embedded command (marked with CAPS)
  String generateEmbeddedCommand({
    required String command,
    String? target,
  }) {
    final commandUpper = command.toUpperCase();
    final targetPhrase = target != null ? ' $target' : '';

    final templates = [
      'I wonder if you\'re ready to $commandUpper$targetPhrase.',
      'Many people find it natural to $commandUpper$targetPhrase when the time is right.',
      'You don\'t even need to try to $commandUpper$targetPhrase—it happens on its own.',
      'Some find they can $commandUpper$targetPhrase without even realizing it.',
      'You might be surprised how easily you $commandUpper$targetPhrase.',
      'Perhaps you\'ve already begun to $commandUpper$targetPhrase.',
      'You can $commandUpper$targetPhrase now, or in a moment—your choice.',
    ];

    return templates[_random.nextInt(templates.length)];
  }

  /// Generates double binds.
  ///
  /// **Double Binds:** Illusion of choice where all options lead to the desired outcome.
  ///
  /// **The Psychology:** People resist being told what to do, but love having choices.
  /// We give them choices... that all achieve our goal.
  ///
  /// **Examples:**
  /// - "You can start now, or take a moment to prepare—either way, you'll begin."
  /// - "Will you enter flow quickly, or let it build gradually?"
  /// - "You might focus deeply right away, or let focus emerge naturally."
  ///
  /// **Parameters:**
  /// - [desiredOutcome]: The goal we want achieved
  /// - [optionA]: First path to outcome
  /// - [optionB]: Second path to outcome
  ///
  /// **Returns:** Double bind sentence
  String generateDoubleBind({
    required String desiredOutcome,
    String? optionA,
    String? optionB,
  }) {
    final pathA = optionA ?? 'immediately';
    final pathB = optionB ?? 'in your own time';

    final templates = [
      'You can $desiredOutcome $pathA, or $pathB—your unconscious knows which is right.',
      'Will you $desiredOutcome $pathA, or would you prefer $pathB? Both work.',
      'Whether you $desiredOutcome $pathA or $pathB, the result is the same.',
      'You might $desiredOutcome $pathA. Or maybe $pathB feels better. Either way, you\'ll $desiredOutcome.',
      'Some people $desiredOutcome $pathA. Others $pathB. What matters is that you $desiredOutcome.',
    ];

    return templates[_random.nextInt(templates.length)];
  }

  /// Generates metaphorical suggestions.
  ///
  /// **Metaphors:** Stories and analogies that bypass logical resistance.
  ///
  /// **The Power:** The conscious mind hears a nice story. The unconscious
  /// understands it's about THEM and implements the lesson.
  ///
  /// **Examples:**
  /// - "A river doesn't force its way past rocks—it flows around them naturally..."
  /// - "Trees don't decide to grow—they simply respond to sunlight..."
  /// - "An athlete entering their zone doesn't think—they become the motion..."
  ///
  /// **Parameters:**
  /// - [challenge]: User's current obstacle ("procrastination", "overthinking", "anxiety")
  /// - [desiredState]: Target condition ("flow", "focus", "calm")
  ///
  /// **Returns:** Metaphorical suggestion
  String generateMetaphor({
    required String challenge,
    required String desiredState,
  }) {
    final metaphorMap = {
      'procrastination': [
        'A seed doesn\'t resist sprouting—it waits for the right conditions, then emerges without effort. Perhaps your $desiredState is the same: not forced, but allowed.',
        'Water finding a path downhill doesn\'t analyze the route—it simply flows. When you stop resisting, $desiredState becomes as natural as gravity.',
      ],
      'overthinking': [
        'A master archer doesn\'t calculate wind speed mid-shot—they feel and release. Your unconscious knows how to achieve $desiredState without conscious interference.',
        'A jazz musician who thinks about every note loses the groove. When you let go of analysis, $desiredState emerges like a perfect improvisation.',
      ],
      'anxiety': [
        'A sailboat doesn\'t fight the wind—it harnesses it. Your energy, even nervous energy, can propel you toward $desiredState when redirected.',
        'A tree bends in the storm but doesn\'t break. When you stop resisting the sensation and simply observe it, you find $desiredState beneath the surface.',
      ],
      'distraction': [
        'A lighthouse beam doesn\'t chase every boat—it shines steadily, and boats find it. When you commit to $desiredState, everything else finds its proper distance.',
        'A conductor doesn\'t play every instrument—they hold the center while the orchestra flows around them. $desiredState is your center; distractions are just the periphery.',
      ],
    };

    final metaphors = metaphorMap[challenge.toLowerCase()] ??
        [
          'Like a river returning to the sea, you naturally find your way to $desiredState when you stop forcing the current.',
          'A flower doesn\'t struggle to bloom—it unfolds. Your path to $desiredState is the same: less effort, more allowing.',
        ];

    return metaphors[_random.nextInt(metaphors.length)];
  }

  /// Generates tag questions (agreement builders).
  ///
  /// **Tag Questions:** Rhetorical questions that build unconscious agreement.
  ///
  /// **The Technique:** When someone agrees with small things ("...don't you?" "...can't you?"),
  /// they're more likely to accept the embedded suggestion.
  ///
  /// **Examples:**
  /// - "You can feel your focus sharpening, can't you?"
  /// - "It's getting easier to filter out distractions, isn't it?"
  /// - "You've noticed improvements already, haven't you?"
  ///
  /// **Parameters:**
  /// - [statement]: The suggestion we want agreement on
  ///
  /// **Returns:** Statement + tag question
  String generateTagQuestion({required String statement}) {
    final tags = [
      'can\'t you?',
      'haven\'t you?',
      'isn\'t it?',
      'don\'t you?',
      'right?',
      'wouldn\'t you say?',
    ];

    final tag = tags[_random.nextInt(tags.length)];
    return '$statement, $tag';
  }

  /// Generates pacing and leading patterns.
  ///
  /// **Pacing & Leading:** State obvious truths (pacing) to build rapport, then
  /// lead toward the desired state.
  ///
  /// **The Formula:**
  /// 1. Pace: "You're sitting here, reading this..."
  /// 2. Pace: "You can feel your device in your hand..."
  /// 3. Pace: "You're breathing naturally..."
  /// 4. **Lead:** "...and your mind is becoming clearer."
  ///
  /// **Why It Works:** After 3 "yeses" (pacing), the mind accepts the lead.
  ///
  /// **Parameters:**
  /// - [currentState]: Observable truths about user's state
  /// - [desiredState]: Where we want to lead them
  ///
  /// **Returns:** Pacing & leading sequence
  String generatePacingAndLeading({
    required List<String> currentState,
    required String desiredState,
  }) {
    if (currentState.isEmpty) {
      return 'As you move forward, you naturally experience $desiredState.';
    }

    final pacing = currentState.join(', and ');
    return '$pacing, and as these things continue, you find yourself moving toward $desiredState.';
  }

  /// Generates a complete focus induction script.
  ///
  /// **Focus Induction:** Multi-pattern hypnotic sequence for entering flow state.
  ///
  /// **Structure:**
  /// 1. Pacing (build rapport with observable truths)
  /// 2. Presupposition (assume focus is happening)
  /// 3. Embedded command (direct unconscious)
  /// 4. Double bind (illusion of control)
  /// 5. Metaphor (bypass resistance)
  ///
  /// **Use Case:** Pre-focus session ritual. Read this, execute task.
  ///
  /// **Returns:** Complete 5-part induction script
  FocusInductionScript generateFocusInduction({
    String challenge = 'distraction',
  }) {
    // **Part 1: Pacing** (observable truths)
    final pacing = generatePacingAndLeading(
      currentState: [
        'you\'re sitting here',
        'you can see this screen',
        'your breathing continues naturally',
      ],
      desiredState: 'a state of deeper focus',
    );

    // **Part 2: Presupposition** (assume it's happening)
    final presupposition = generatePresupposition(
      action: 'focusing on what matters most',
      timeFrame: TimeFrame.as_,
    );

    // **Part 3: Embedded Command** (direct unconscious)
    final embeddedCommand = generateEmbeddedCommand(
      command: 'FILTER OUT',
      target: 'the unnecessary',
    );

    // **Part 4: Double Bind** (controlled choice)
    final doubleBind = generateDoubleBind(
      desiredOutcome: 'enter flow',
      optionA: 'in the next minute',
      optionB: 'as you ease into the work',
    );

    // **Part 5: Metaphor** (story bypass)
    final metaphor = generateMetaphor(
      challenge: challenge,
      desiredState: 'flow',
    );

    return FocusInductionScript(
      pacing: pacing,
      presupposition: presupposition,
      embeddedCommand: embeddedCommand,
      doubleBind: doubleBind,
      metaphor: metaphor,
    );
  }

  /// Random time frame helper
  TimeFrame _randomTimeFrame() {
    const frames = TimeFrame.values;
    return frames[_random.nextInt(frames.length)];
  }
}

// =============================================================================
// ENUMS & DATA CLASSES
// =============================================================================

/// Time frame markers for presuppositions
enum TimeFrame {
  as_, // "As you..."
  when, // "When you..."
  before, // "Before you..."
  after, // "After you..."
  while_, // "While you..."
}

/// Complete focus induction script
class FocusInductionScript {
  /// Part 1: Observable truths to build rapport
  final String pacing;

  /// Part 2: Assume focus is already happening
  final String presupposition;

  /// Part 3: Hidden directive to unconscious
  final String embeddedCommand;

  /// Part 4: Controlled choice (all roads lead to flow)
  final String doubleBind;

  /// Part 5: Metaphorical bypass of resistance
  final String metaphor;

  const FocusInductionScript({
    required this.pacing,
    required this.presupposition,
    required this.embeddedCommand,
    required this.doubleBind,
    required this.metaphor,
  });

  /// Combines all parts into full script
  String get fullScript => '''
$pacing

$presupposition

$embeddedCommand

$doubleBind

$metaphor
  '''
      .trim();

  /// Returns script as structured data (for AI to speak)
  Map<String, String> toMap() => {
        'pacing': pacing,
        'presupposition': presupposition,
        'embedded_command': embeddedCommand,
        'double_bind': doubleBind,
        'metaphor': metaphor,
      };
}

// =============================================================================
// PATTERN LIBRARY (Pre-built High-Quality Patterns)
// =============================================================================

/// **Curated Milton Model Pattern Library**
///
/// Hand-crafted by NLP Master Practitioners. Like having Anthony Robbins
/// and Richard Bandler in your pocket.
class MiltonModelLibrary {
  /// Focus & concentration patterns
  static const List<String> focusPatterns = [
    'As you sit there, noticing the interface, your breathing begins to slow naturally. And as that slowing continues, your mind can begin to filter out the unnecessary, leaving only the clarity of the task at hand.',
    'You don\'t even need to realize how deeply you\'re focusing until you find the work is already done.',
    'When you allow your unconscious to handle the details, focus becomes effortless—like breathing.',
  ];

  /// Procrastination pattern interrupts
  static const List<String> procrastinationInterrupts = [
    'I wonder what would happen if you started before you felt ready. Just for a moment. Just to see.',
    'You can begin now, or you can prepare a bit more. Either way, that first step will happen. The question is: when will you give yourself permission?',
    'Procrastination is just your mind\'s way of asking, "Is this truly important?" If it is, starting—even imperfectly—answers that question.',
  ];

  /// Stress reduction patterns
  static const List<String> stressReduction = [
    'Imagine tension as a color. As you breathe, that color begins to soften, fade, and finally dissolve into the background.',
    'Your nervous system doesn\'t need your permission to relax—it\'s already looking for any excuse to let go.',
    'The more you try to force calm, the more elusive it becomes. But when you simply observe the stress without judgment, it begins to settle on its own.',
  ];

  /// Confidence & self-efficacy boosters
  static const List<String> confidenceBuilders = [
    'You\'ve solved harder problems than this—your unconscious remembers even if you don\'t.',
    'Confidence isn\'t about knowing you\'ll succeed. It\'s about knowing you\'ll handle whatever comes.',
    'Every expert was once exactly where you are now, wondering if they could. The difference? They moved forward anyway.',
  ];
}
