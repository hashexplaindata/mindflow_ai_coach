/// Onboarding Question Model
/// Represents a single profiling question with its options
class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.question,
    required this.subtitle,
    required this.optionA,
    required this.optionB,
    required this.dimension, // Which PersonalityVector dimension this impacts
    this.optionC,
  });

  final String id;
  final String question;
  final String subtitle;
  final QuestionOption optionA;
  final QuestionOption optionB;
  final QuestionOption? optionC;
  final String dimension; // discipline, novelty, volatility, structure

  List<QuestionOption> get options => [
        optionA,
        optionB,
        if (optionC != null) optionC!,
      ];
}

class QuestionOption {
  const QuestionOption({
    required this.value,
    required this.label,
    required this.description,
    required this.scoreImpact, // How this affects the dimension (0.0 to 1.0)
    this.emoji,
  });

  final String value;
  final String label;
  final String description;
  final double scoreImpact;
  final String? emoji;
}

/// The 5 "Psychologically Engineered" Questions
/// Maps directly to PersonalityVector dimensions
class OnboardingQuestions {
  OnboardingQuestions._();

  static const List<OnboardingQuestion> questions = [
    // 1. STRUCTURE Needs (Grid vs Flow)
    OnboardingQuestion(
      id: 'structure_pref',
      dimension: 'structure',
      question: 'How do you handle a new complex project?',
      subtitle: 'Be honest about your natural instinct',
      optionA: QuestionOption(
        value: 'high_structure',
        label: 'Step-by-step plan',
        description: 'I need a clear roadmap before I start',
        scoreImpact: 0.9, // High Structure
        emoji: '📋',
      ),
      optionB: QuestionOption(
        value: 'low_structure',
        label: 'Jump in & figure it out',
        description: 'I prefer to explore and adapt as I go',
        scoreImpact: 0.2, // Low Structure
        emoji: '🌊',
      ),
    ),

    // 2. NOVELTY Needs (Seeker vs Traditional)
    OnboardingQuestion(
      id: 'novelty_pref',
      dimension: 'novelty',
      question: 'Your ideal weekend looks like:',
      subtitle: 'What recharges you?',
      optionA: QuestionOption(
        value: 'high_novelty',
        label: 'Trying something new',
        description: 'New places, potential chaos, excitement',
        scoreImpact: 0.9, // High Novelty
        emoji: '🌟',
      ),
      optionB: QuestionOption(
        value: 'low_novelty',
        label: 'Comfort & routine',
        description: 'Resting in a familiar, peaceful space',
        scoreImpact: 0.2, // Low Novelty
        emoji: '🏠',
      ),
    ),

    // 3. VOLATILITY / Emotional Reactivity (Reactive vs Stoic)
    OnboardingQuestion(
      id: 'volatility_pref',
      dimension: 'volatility',
      question: 'When things go wrong, you tend to:',
      subtitle: 'Your immediate reaction',
      optionA: QuestionOption(
        value: 'high_volatility',
        label: 'Feel it intensely',
        description: 'I need to process the frustration/emotion',
        scoreImpact: 0.8, // High Volatility (needs validation)
        emoji: '❤️‍🔥',
      ),
      optionB: QuestionOption(
        value: 'low_volatility',
        label: 'Go into fix-it mode',
        description: 'I detach and focus on the solution',
        scoreImpact: 0.3, // Low Volatility (needs tough love/logic)
        emoji: '🤖',
      ),
    ),

    // 4. DISCIPLINE / Approach (Order vs Chaos)
    OnboardingQuestion(
      id: 'discipline_pref',
      dimension: 'discipline',
      question: 'Your relationship with deadlines:',
      subtitle: 'How you actually work',
      optionA: QuestionOption(
        value: 'high_discipline',
        label: 'Early & Ready',
        description: 'I finish early to avoid stress',
        scoreImpact: 0.8, // High Discipline
        emoji: '✅',
      ),
      optionB: QuestionOption(
        value: 'low_discipline',
        label: 'Pressure Performer',
        description: 'I do my best work at the last minute',
        scoreImpact: 0.3, // Low Discipline (needs constraints)
        emoji: '⏰',
      ),
    ),

    // 5. MOTIVATION (Toward vs Away) - Maps to Volatility/Novelty mix usually, but let's keep it simple
    // We'll map this to a slight modifier on Novelty/Discipline
    OnboardingQuestion(
      id: 'motivation_pref',
      dimension: 'novelty', // Using this to fine-tune Novelty/Ambition
      question: 'What drives you more?',
      subtitle: 'The carrot or the stick?',
      optionA: QuestionOption(
        value: 'toward',
        label: 'Achieving goals',
        description: 'The excitement of the win',
        scoreImpact: 0.8, // High Drive (Modifies Novelty+)
        emoji: '🏆',
      ),
      optionB: QuestionOption(
        value: 'away',
        label: 'Avoiding failure',
        description: 'The fear of messing up',
        scoreImpact: 0.4, // Protection (Modifies Novelty-)
        emoji: '🛡️',
      ),
    ),
  ];
}
