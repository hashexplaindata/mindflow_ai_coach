/// Onboarding Question Model
/// Represents a single profiling question with its options
class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.question,
    required this.subtitle,
    required this.optionA,
    required this.optionB,
    required this.metaProgram,
    this.optionC,
  });

  /// Unique identifier for the question
  final String id;

  /// The main question text
  final String question;

  /// Subtitle/context for the question
  final String subtitle;

  /// First option (usually "toward" / "internal" / "visual")
  final QuestionOption optionA;

  /// Second option (usually "away_from" / "external" / "auditory")
  final QuestionOption optionB;

  /// Third option (optional, for thinking style)
  final QuestionOption? optionC;

  /// Which meta-program this question measures
  final String metaProgram;

  /// Get all options as a list
  List<QuestionOption> get options => [
    optionA,
    optionB,
    if (optionC != null) optionC!,
  ];
}

/// A single option for a question
class QuestionOption {
  const QuestionOption({
    required this.value,
    required this.label,
    required this.description,
    this.emoji,
  });

  /// The value to store (e.g., "toward", "visual")
  final String value;

  /// Short label text
  final String label;

  /// Longer description of what this means
  final String description;

  /// Optional emoji to display
  final String? emoji;
}

/// The 5 NLP profiling questions
/// Based on Tad James meta-programs and Bandler/Grinder systems
class OnboardingQuestions {
  OnboardingQuestions._();

  static const List<OnboardingQuestion> questions = [
    // Question 1: Motivation Direction (Toward vs Away-From)
    OnboardingQuestion(
      id: 'motivation',
      metaProgram: 'motivation',
      question: 'When you think about change, what drives you more?',
      subtitle: 'There\'s no right answer - just what feels true for you',
      optionA: QuestionOption(
        value: 'toward',
        label: 'Exciting possibilities',
        description: 'I\'m energized by what I could achieve and gain',
        emoji: '🚀',
      ),
      optionB: QuestionOption(
        value: 'away_from',
        label: 'Problems to solve',
        description: 'I\'m motivated to fix issues and avoid problems',
        emoji: '🛡️',
      ),
    ),

    // Question 2: Reference Frame (Internal vs External)
    OnboardingQuestion(
      id: 'reference',
      metaProgram: 'reference',
      question: 'When making important decisions, you tend to:',
      subtitle: 'Think about your last big decision',
      optionA: QuestionOption(
        value: 'internal',
        label: 'Trust my gut',
        description: 'I know inside when something is right for me',
        emoji: '💭',
      ),
      optionB: QuestionOption(
        value: 'external',
        label: 'Seek outside input',
        description: 'I value research, experts, and others\' opinions',
        emoji: '📊',
      ),
    ),

    // Question 3: Representational System (Visual/Auditory/Kinesthetic)
    OnboardingQuestion(
      id: 'thinking',
      metaProgram: 'thinking',
      question: 'When you imagine your ideal future, you:',
      subtitle: 'Notice what happens naturally when you imagine',
      optionA: QuestionOption(
        value: 'visual',
        label: 'See vivid pictures',
        description: 'I visualize scenes, colors, and images clearly',
        emoji: '👁️',
      ),
      optionB: QuestionOption(
        value: 'auditory',
        label: 'Hear inner dialogue',
        description: 'I think in words, sounds, and conversations',
        emoji: '👂',
      ),
      optionC: QuestionOption(
        value: 'kinesthetic',
        label: 'Feel the emotions',
        description: 'I sense it in my body and gut feelings',
        emoji: '✋',
      ),
    ),

    // Question 4: Processing Preference (Options vs Procedures)
    OnboardingQuestion(
      id: 'processing',
      metaProgram: 'processing',
      question: 'When starting something new, you prefer:',
      subtitle: 'Think about learning a new skill',
      optionA: QuestionOption(
        value: 'options',
        label: 'Explore possibilities',
        description: 'Show me the options and let me figure it out',
        emoji: '🎨',
      ),
      optionB: QuestionOption(
        value: 'procedures',
        label: 'Follow a system',
        description: 'Give me clear steps that work',
        emoji: '📋',
      ),
    ),

    // Question 5: Change Preference (Sameness vs Difference)
    OnboardingQuestion(
      id: 'change',
      metaProgram: 'change',
      question: 'In your daily life, you value:',
      subtitle: 'Think about your comfort zone',
      optionA: QuestionOption(
        value: 'sameness',
        label: 'Stability & routine',
        description: 'I like consistent patterns and reliable habits',
        emoji: '🏠',
      ),
      optionB: QuestionOption(
        value: 'difference',
        label: 'Variety & novelty',
        description: 'I crave new experiences and change',
        emoji: '🌟',
      ),
    ),
  ];

  /// Get a question by its id
  static OnboardingQuestion? getById(String id) {
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }
}
