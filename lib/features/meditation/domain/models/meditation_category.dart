enum MeditationCategory {
  stress,
  anxiety,
  sleep,
  focus,
  relationships,
  selfEsteem,
}

extension MeditationCategoryExtension on MeditationCategory {
  String get displayName {
    switch (this) {
      case MeditationCategory.stress:
        return 'Stress';
      case MeditationCategory.anxiety:
        return 'Anxiety';
      case MeditationCategory.sleep:
        return 'Sleep';
      case MeditationCategory.focus:
        return 'Focus';
      case MeditationCategory.relationships:
        return 'Relationships';
      case MeditationCategory.selfEsteem:
        return 'Self-Esteem';
    }
  }

  String get icon {
    switch (this) {
      case MeditationCategory.stress:
        return '🧘';
      case MeditationCategory.anxiety:
        return '🌊';
      case MeditationCategory.sleep:
        return '🌙';
      case MeditationCategory.focus:
        return '🎯';
      case MeditationCategory.relationships:
        return '💕';
      case MeditationCategory.selfEsteem:
        return '✨';
    }
  }
}
