import 'package:mindflow_ai_coach/core/services/music/frequency_registry.dart';

/// Bridges the gap between Natural Language Processing (User Intent)
/// and Acoustic Engineering (Frequency Prescription).
class NLPToMusicBridge {
  /// Analyzes user input or detected state to recommend a specific acoustic therapy.
  AudioPrescription prescribe(String userStatement,
      {List<String>? detectedTags}) {
    // 1. Analyze keywords in the statement
    final statementLower = userStatement.toLowerCase();

    // Map of Keywords -> Search Terms for FrequencyRegistry
    final intentMap = {
      'anxious': 'anxiety',
      'stress': 'stress',
      'tired': 'energy',
      'exhausted': 'regeneration',
      'pain': 'pain',
      'focus': 'focus',
      'study': 'learning',
      'can\'t sleep': 'sleep',
      'insomnia': 'sleep',
      'meditate': 'meditation',
      'create': 'creativity',
      'stuck': 'creativity', // Being stuck often needs creative unblocking
      'sad': 'mood',
      'depressed': 'depression',
      'fear': 'fear',
      'hurt': 'healing',
    };

    String? bestMatchEffect;

    // Check direct keywords
    for (var entry in intentMap.entries) {
      if (statementLower.contains(entry.key)) {
        bestMatchEffect = entry.value;
        break; // Prioritize first match for now
      }
    }

    // Check tags if provided
    if (bestMatchEffect == null && detectedTags != null) {
      for (var tag in detectedTags) {
        if (intentMap.containsKey(tag.toLowerCase())) {
          bestMatchEffect = intentMap[tag.toLowerCase()];
          break;
        }
      }
    }

    // Default to Relaxation if nothing specific found but input suggests distress
    if (bestMatchEffect == null) {
      if (statementLower.contains('help') || statementLower.contains('bad')) {
        bestMatchEffect = 'relaxation';
      }
    }

    if (bestMatchEffect != null) {
      final frequencies = FrequencyRegistry.findByEffect(bestMatchEffect);
      if (frequencies.isNotEmpty) {
        // Simple selection strategy: Pick the first or most "specific" one.
        // For now, return the first match.
        final freq = frequencies.first;
        return AudioPrescription(
          targetFrequency: freq,
          reason: 'Detected need for $bestMatchEffect. ${freq.description}',
          suggestedDurationMinutes: 15,
        );
      }
    }

    return AudioPrescription.neutral();
  }
}

class AudioPrescription {
  final FrequencyDefinition? targetFrequency;
  final String reason;
  final int suggestedDurationMinutes;

  const AudioPrescription({
    this.targetFrequency,
    required this.reason,
    this.suggestedDurationMinutes = 10,
  });

  factory AudioPrescription.neutral() {
    return const AudioPrescription(
      reason: 'No specific acoustic therapy needed detected.',
      targetFrequency: null,
    );
  }

  bool get hasPrescription => targetFrequency != null;
}
