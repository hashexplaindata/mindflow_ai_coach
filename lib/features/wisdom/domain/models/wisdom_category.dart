enum WisdomCategory {
  quote,
  affirmation,
  gratitudePrompt,
  insight,
}

extension WisdomCategoryExtension on WisdomCategory {
  String get displayName {
    switch (this) {
      case WisdomCategory.quote:
        return 'Quote';
      case WisdomCategory.affirmation:
        return 'Affirmation';
      case WisdomCategory.gratitudePrompt:
        return 'Gratitude Prompt';
      case WisdomCategory.insight:
        return 'Insight';
    }
  }

  String get emoji {
    switch (this) {
      case WisdomCategory.quote:
        return '💭';
      case WisdomCategory.affirmation:
        return '✨';
      case WisdomCategory.gratitudePrompt:
        return '🙏';
      case WisdomCategory.insight:
        return '🌱';
    }
  }
}

enum WisdomTone {
  motivation,
  calm,
  mindfulness,
  growth,
  gratitude,
}

extension WisdomToneExtension on WisdomTone {
  String get displayName {
    switch (this) {
      case WisdomTone.motivation:
        return 'Motivation';
      case WisdomTone.calm:
        return 'Calm';
      case WisdomTone.mindfulness:
        return 'Mindfulness';
      case WisdomTone.growth:
        return 'Growth';
      case WisdomTone.gratitude:
        return 'Gratitude';
    }
  }

  String get emoji {
    switch (this) {
      case WisdomTone.motivation:
        return '🔥';
      case WisdomTone.calm:
        return '🌊';
      case WisdomTone.mindfulness:
        return '🧘';
      case WisdomTone.growth:
        return '🌳';
      case WisdomTone.gratitude:
        return '💛';
    }
  }
}
