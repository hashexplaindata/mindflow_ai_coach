/// Registry of frequencies and their associated effects on the human mind/body.
/// Based on detailed documentation from `docs/core logic/Frequencies.md`.
class FrequencyRegistry {
  static const List<FrequencyDefinition> brainwaves = [
    FrequencyDefinition(
      category: 'Delta',
      rangeMin: 0.1,
      rangeMax: 4.0,
      description: 'Deep sleep, lucid dreaming, immune function, healing.',
      effects: ['Deep Sleep', 'Healing', 'Pain Relief', 'Anti-aging'],
    ),
    FrequencyDefinition(
      category: 'Theta',
      rangeMin: 4.0,
      rangeMax: 8.0,
      description: 'Deep relaxation, meditation, creativity, memory.',
      effects: ['Meditation', 'Creativity', 'Memory', 'Focus'],
    ),
    FrequencyDefinition(
      category: 'Alpha',
      rangeMin: 8.0,
      rangeMax: 14.0,
      description: 'Relaxed focus, super learning, positive thinking.',
      effects: ['Relaxation', 'Learning', 'Mood Elevation', 'Stress Reduction'],
    ),
    FrequencyDefinition(
      category: 'Beta',
      rangeMin: 14.0,
      rangeMax: 30.0,
      description: 'Focused attention, alertness, analytical thinking.',
      effects: ['Focus', 'Alertness', 'Problem Solving', 'Energy'],
    ),
    FrequencyDefinition(
      category: 'Gamma',
      rangeMin: 30.0,
      rangeMax: 100.0,
      description: 'High-level information processing, insight, peak focus.',
      effects: ['Insight', 'Peak Performance', 'Cognitive Enhancement'],
    ),
  ];

  static const List<FrequencyDefinition> solfeggio = [
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 174.0,
      description: 'Pain relief, foundation, security.',
      effects: ['Pain Relief', 'Security'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 285.0,
      description: 'Tissue regeneration, healing burns/wounds.',
      effects: ['Healing', 'Regeneration'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 396.0,
      description: 'Liberating guilt and fear.',
      effects: ['Guilt Release', 'Fear Release'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 417.0,
      description: 'Undoing situations and facilitating change.',
      effects: ['Change', 'Clearing Negativity'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 528.0,
      description: 'Transformation and miracles (DNA Repair).',
      effects: ['DNA Repair', 'Miracles', 'Love'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 639.0,
      description: 'Connecting/Relationships.',
      effects: ['Relationships', 'Connection'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 741.0,
      description: 'Expression/Solutions.',
      effects: ['Expression', 'Solutions', 'Detox'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 852.0,
      description: 'Returning to Spiritual Order.',
      effects: ['Intuition', 'Spiritual Order'],
    ),
    FrequencyDefinition(
      category: 'Solfeggio',
      baseFrequency: 963.0,
      description: 'Awakening Perfect State.',
      effects: ['Higher Consciousness', 'Oneness'],
    ),
  ];

  static const List<FrequencyDefinition> specificHealing = [
    FrequencyDefinition(
      category: 'Healing',
      baseFrequency: 10.0,
      description: 'Mood elevator, analgesic, circadian rhythm resync.',
      effects: ['Mood', 'Pain Relief', 'Energy'],
    ),
    FrequencyDefinition(
      category: 'Healing',
      baseFrequency: 40.0,
      description: 'Problem solving in fearful situations, binding mechanism.',
      effects: ['Focus', 'Problem Solving', 'Anxiety Relief'],
    ),
    FrequencyDefinition(
      category: 'Healing',
      baseFrequency: 7.83,
      description: 'Schumann Resonance (Earth Frequency). Grounding.',
      effects: ['Grounding', 'Rejuvenation', 'Stress Tolerance'],
    ),
    FrequencyDefinition(
      category: 'Healing',
      baseFrequency: 111.0,
      description: 'Beta endorphins, cell regeneration.',
      effects: ['Regeneration', 'Endorphins'],
    ),
  ];

  /// Finds frequencies matching a specific effect keyword (e.g. "Anxiety").
  static List<FrequencyDefinition> findByEffect(String effect) {
    final lowerEffect = effect.toLowerCase();
    return [...brainwaves, ...solfeggio, ...specificHealing]
        .where((freq) =>
            freq.effects.any((e) => e.toLowerCase().contains(lowerEffect)) ||
            freq.description.toLowerCase().contains(lowerEffect))
        .toList();
  }
}

class FrequencyDefinition {
  final String category;
  final double? baseFrequency;
  final double? rangeMin;
  final double? rangeMax;
  final String description;
  final List<String> effects;

  const FrequencyDefinition({
    required this.category,
    this.baseFrequency,
    this.rangeMin,
    this.rangeMax,
    required this.description,
    required this.effects,
  });

  bool get isRange => rangeMin != null && rangeMax != null;
  String get label => baseFrequency != null
      ? '$baseFrequency Hz'
      : '$rangeMin-$rangeMax Hz';
}
