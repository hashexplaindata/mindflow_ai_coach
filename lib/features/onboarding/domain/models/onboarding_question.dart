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
      question: 'New Project Strategy:',
      subtitle: 'Instinctive approach',
      optionA: QuestionOption(
        value: 'high_structure',
        label: 'Detailed Roadmap',
        description: 'Plan first, execute second.',
        scoreImpact: 0.9,
        emoji: '📋',
      ),
      optionB: QuestionOption(
        value: 'low_structure',
        label: 'Figure it out',
        description: 'Start now, adapt later.',
        scoreImpact: 0.2,
        emoji: '🌊',
      ),
    ),

    // 2. NOVELTY Needs (Seeker vs Traditional)
    OnboardingQuestion(
      id: 'novelty_pref',
      dimension: 'novelty',
      question: 'Weekend Preference:',
      subtitle: 'What recharges you?',
      optionA: QuestionOption(
        value: 'high_novelty',
        label: 'Novelty & Chaos',
        description: 'New places, high stimulation.',
        scoreImpact: 0.9,
        emoji: '🌟',
      ),
      optionB: QuestionOption(
        value: 'low_novelty',
        label: 'Routine & Peace',
        description: 'Familiar comfort, low noise.',
        scoreImpact: 0.2,
        emoji: '🏠',
      ),
    ),

    // 3. VOLATILITY (Reactive vs Stoic)
    OnboardingQuestion(
      id: 'volatility_pref',
      dimension: 'volatility',
      question: 'Reaction to Failure:',
      subtitle: 'Gut response',
      optionA: QuestionOption(
        value: 'high_volatility',
        label: 'Intense Emotion',
        description: 'I feel the frustration deeply.',
        scoreImpact: 0.8,
        emoji: '❤️‍🔥',
      ),
      optionB: QuestionOption(
        value: 'low_volatility',
        label: 'Cold Logic',
        description: 'Detach and analyze the fix.',
        scoreImpact: 0.3,
        emoji: '🤖',
      ),
    ),

    // 4. DISCIPLINE (Order vs Pressure)
    OnboardingQuestion(
      id: 'discipline_pref',
      dimension: 'discipline',
      question: 'Deadline Style:',
      subtitle: 'Work flow',
      optionA: QuestionOption(
        value: 'high_discipline',
        label: 'Early & Steady',
        description: 'Finished days in advance.',
        scoreImpact: 0.8,
        emoji: '✅',
      ),
      optionB: QuestionOption(
        value: 'low_discipline',
        label: 'Pressure Cooker',
        description: 'Sprint at the last minute.',
        scoreImpact: 0.3,
        emoji: '⏰',
      ),
    ),
  ];
}
