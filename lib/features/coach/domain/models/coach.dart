enum CoachNLPType {
  milton, // Hypnotic, indirect, metaphorical
  meta,   // Precision questioning, challenging
  vak,    // Sensory-aware, mirroring
  bayesian, // Data-driven, analytical
  wellness, // Mindfulness, meditation (Default)
  productivity, // Systems, minimalism (Simon's style)
}

class Coach {
  final String id;
  final String name;
  final String avatarPath;
  final String specialty;
  final String description;
  final CoachNLPType nlpType;
  final String systemPromptBase;
  final String tone;
  final bool isPremium;

  const Coach({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.specialty,
    required this.description,
    required this.nlpType,
    required this.systemPromptBase,
    required this.tone,
    this.isPremium = false,
  });

  // Default "MindFlow" coach
  static const Coach defaultCoach = Coach(
    id: 'mindflow_core',
    name: 'MindFlow',
    avatarPath: 'assets/images/coach_avatar_default.png',
    specialty: 'Holistic Wellness',
    description: 'Your personal guide to mindfulness and flow.',
    nlpType: CoachNLPType.wellness,
    systemPromptBase: 'You are MindFlow, a compassionate and wise AI coach.',
    tone: 'Warm, calm, and insightful',
    isPremium: false,
  );
}
