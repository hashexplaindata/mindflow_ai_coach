/// **Frequency Protocol Library**
///
/// Curated therapeutic protocols based on extensive brainwave research.
/// Reference: docs/core logic/Frequencies.md
///
/// **Core Principles:**
/// - Brainwave entrainment through binaural beats
/// - Schumann Resonance for grounding
/// - Chakra frequencies for energy alignment
/// - Solfeggio frequencies for healing
library frequency_protocols;

// Core imports handled by flutter/foundation

// =============================================================================
// BRAINWAVE FREQUENCY RANGES
// =============================================================================

/// Brainwave states and their frequency ranges
enum BrainwaveState {
  /// 0.5-4 Hz: Deep sleep, healing, trauma recovery
  delta,

  /// 4-8 Hz: Meditation, creativity, memory, lucid dreaming
  theta,

  /// 8-12 Hz: Relaxation, learning, flow state
  alpha,

  /// 12-15 Hz: Relaxed focus, SMR training, attention
  lowBeta,

  /// 15-20 Hz: Mental clarity, IQ enhancement
  midBeta,

  /// 20-30 Hz: High alertness, peak performance
  highBeta,

  /// 30-40+ Hz: Peak cognition, problem solving, binding
  gamma,
}

/// Extension to get frequency range for each brainwave state
extension BrainwaveStateExtension on BrainwaveState {
  /// Minimum frequency in Hz
  double get minFrequency {
    switch (this) {
      case BrainwaveState.delta:
        return 0.5;
      case BrainwaveState.theta:
        return 4.0;
      case BrainwaveState.alpha:
        return 8.0;
      case BrainwaveState.lowBeta:
        return 12.0;
      case BrainwaveState.midBeta:
        return 15.0;
      case BrainwaveState.highBeta:
        return 20.0;
      case BrainwaveState.gamma:
        return 30.0;
    }
  }

  /// Maximum frequency in Hz
  double get maxFrequency {
    switch (this) {
      case BrainwaveState.delta:
        return 4.0;
      case BrainwaveState.theta:
        return 8.0;
      case BrainwaveState.alpha:
        return 12.0;
      case BrainwaveState.lowBeta:
        return 15.0;
      case BrainwaveState.midBeta:
        return 20.0;
      case BrainwaveState.highBeta:
        return 30.0;
      case BrainwaveState.gamma:
        return 45.0;
    }
  }

  /// Optimal/center frequency for this state
  double get optimalFrequency => (minFrequency + maxFrequency) / 2;

  /// Human-readable description
  String get description {
    switch (this) {
      case BrainwaveState.delta:
        return 'Deep sleep, healing, trauma recovery';
      case BrainwaveState.theta:
        return 'Meditation, creativity, memory';
      case BrainwaveState.alpha:
        return 'Relaxation, learning, flow state';
      case BrainwaveState.lowBeta:
        return 'Relaxed focus, attention';
      case BrainwaveState.midBeta:
        return 'Mental clarity, alertness';
      case BrainwaveState.highBeta:
        return 'High alertness, peak performance';
      case BrainwaveState.gamma:
        return 'Peak cognition, problem solving';
    }
  }

  /// Therapeutic benefits
  List<String> get benefits {
    switch (this) {
      case BrainwaveState.delta:
        return [
          'Deep restorative sleep',
          'Immune system boost',
          'HGH release',
          'Trauma recovery',
          'Anti-aging (DHEA increase)',
        ];
      case BrainwaveState.theta:
        return [
          'Enhanced creativity',
          'Deep meditation',
          'Memory consolidation',
          'Lucid dreaming',
          'Subconscious access',
        ];
      case BrainwaveState.alpha:
        return [
          'Stress reduction',
          'Accelerated learning',
          'Positive thinking',
          'Mind/body integration',
          'Serotonin release',
        ];
      case BrainwaveState.lowBeta:
        return [
          'Improved focus',
          'Reduced hyperactivity',
          'Better attention span',
          'Calm alertness',
        ];
      case BrainwaveState.midBeta:
        return [
          'Enhanced IQ',
          'Improved memory',
          'Mental clarity',
          'Better reading/spelling',
        ];
      case BrainwaveState.highBeta:
        return [
          'Peak alertness',
          'High energy',
          'Fast thinking',
          'Problem solving',
        ];
      case BrainwaveState.gamma:
        return [
          'Information synthesis',
          'Insight and intuition',
          'Higher consciousness',
          'Binding of senses',
        ];
    }
  }
}

// =============================================================================
// SCHUMANN RESONANCES (EARTH FREQUENCIES)
// =============================================================================

/// Schumann Resonance frequencies - Earth's electromagnetic heartbeat
class SchumannResonance {
  /// Primary frequency: 7.83 Hz (most important)
  static const double primary = 7.83;

  /// All 7 Schumann harmonics
  static const List<double> harmonics = [
    7.83, // 1st - Primary (grounding, anti-stress)
    14.0, // 2nd - Alertness, concentration
    20.0, // 3rd - Pineal stimulation
    26.0, // 4th - Growth hormone release
    33.0, // 5th - Christ consciousness, pyramid frequency
    39.0, // 6th - Higher awareness
    45.0, // 7th - Peak gamma
  ];

  /// Get frequency description
  static String getDescription(int index) {
    switch (index) {
      case 0:
        return 'Earth grounding, anti-stress, healing';
      case 1:
        return 'Alertness, concentration, focus';
      case 2:
        return 'Pineal stimulation, subconscious';
      case 3:
        return 'Growth hormone, rejuvenation';
      case 4:
        return 'Higher consciousness, pyramid frequency';
      case 5:
        return 'Higher awareness';
      case 6:
        return 'Peak cognitive binding';
      default:
        return 'Unknown harmonic';
    }
  }
}

// =============================================================================
// SOLFEGGIO FREQUENCIES (ANCIENT HEALING TONES)
// =============================================================================

/// Solfeggio healing frequencies
enum SolfeggioFrequency {
  /// 396 Hz - Liberating guilt and fear
  ut(396, 'UT', 'Liberation', 'Liberating guilt and fear'),

  /// 417 Hz - Undoing situations
  re(417, 'RE', 'Change', 'Undoing situations, facilitating change'),

  /// 528 Hz - Transformation and miracles (DNA repair)
  mi(528, 'MI', 'Transformation', 'DNA repair, miracles, transformation'),

  /// 639 Hz - Connecting relationships
  fa(639, 'FA', 'Connection', 'Connecting relationships, harmony'),

  /// 741 Hz - Awakening intuition
  sol(741, 'SOL', 'Awakening', 'Awakening intuition, expression'),

  /// 852 Hz - Returning to spiritual order
  la(852, 'LA', 'Intuition', 'Returning to spiritual order');

  final double frequency;
  final String note;
  final String keyword;
  final String description;

  const SolfeggioFrequency(
      this.frequency, this.note, this.keyword, this.description);
}

// =============================================================================
// CHAKRA FREQUENCIES
// =============================================================================

/// Chakra frequency mappings (BH3 Reference from Frequencies.md)
enum Chakra {
  /// Root/Muladhara - 256 Hz (C)
  root(256, 'C', 'Muladhara', 0xFFFF0000, 'Physical energy, grounding'),

  /// Sacral/Svadhisthana - 288 Hz (D)
  sacral(288, 'D', 'Svadhisthana', 0xFFFF8C00, 'Creativity, sexuality'),

  /// Solar Plexus/Manipura - 320 Hz (Eb)
  solarPlexus(320, 'Eb', 'Manipura', 0xFFFFFF00, 'Personal power, will'),

  /// Heart/Anahata - 341 Hz (F)
  heart(341, 'F', 'Anahata', 0xFF00FF00, 'Love, compassion'),

  /// Throat/Vishuddha - 384 Hz (G)
  throat(384, 'G', 'Vishuddha', 0xFF00BFFF, 'Communication, expression'),

  /// Third Eye/Ajna - 448 Hz (A)
  thirdEye(448, 'A', 'Ajna', 0xFF4B0082, 'Intuition, visualization'),

  /// Crown/Sahasrara - 480 Hz (B)
  crown(480, 'B', 'Sahasrara', 0xFF8B00FF, 'Spirituality, consciousness');

  final double frequency;
  final String note;
  final String sanskritName;
  final int colorValue;
  final String description;

  const Chakra(this.frequency, this.note, this.sanskritName, this.colorValue,
      this.description);

  /// Get chakra aligned frequencies for a full sequence
  static List<double> get fullSequence =>
      Chakra.values.map((c) => c.frequency).toList();
}

// =============================================================================
// THERAPEUTIC PROTOCOLS
// =============================================================================

/// A single frequency step in a protocol
class FrequencyStep {
  /// Target frequency in Hz
  final double frequency;

  /// Duration of this step in seconds
  final int durationSeconds;

  /// Human-readable purpose of this step
  final String purpose;

  /// Volume multiplier (0.0 - 1.0)
  final double volumeMultiplier;

  const FrequencyStep({
    required this.frequency,
    required this.durationSeconds,
    required this.purpose,
    this.volumeMultiplier = 1.0,
  });

  @override
  String toString() =>
      'FrequencyStep(${frequency}Hz for ${durationSeconds}s: $purpose)';
}

/// A complete therapeutic protocol with frequency sequence
class TherapeuticProtocol {
  /// Unique identifier
  final String id;

  /// Human-readable name
  final String name;

  /// Protocol description
  final String description;

  /// Sequence of frequency steps
  final List<FrequencyStep> steps;

  /// Recommended BPM for Lo-Fi rhythm layer (null = no rhythm)
  final int? bpm;

  /// Whether to include Lo-Fi textures
  final bool includeLoFiTextures;

  /// Target brainwave states this protocol aims for
  final List<BrainwaveState> targetStates;

  const TherapeuticProtocol({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.bpm,
    this.includeLoFiTextures = true,
    this.targetStates = const [],
  });

  /// Total duration in seconds
  int get totalDurationSeconds =>
      steps.fold(0, (sum, step) => sum + step.durationSeconds);

  /// Total duration in minutes
  double get totalDurationMinutes => totalDurationSeconds / 60.0;

  /// Get step at a given elapsed time (seconds from start)
  FrequencyStep? getStepAt(int elapsedSeconds) {
    int accumulated = 0;
    for (final step in steps) {
      accumulated += step.durationSeconds;
      if (elapsedSeconds < accumulated) {
        return step;
      }
    }
    return steps.isNotEmpty ? steps.last : null;
  }

  /// Get frequency at a given elapsed time with smooth interpolation
  double getFrequencyAt(int elapsedSeconds) {
    if (steps.isEmpty) return 10.0; // Default to alpha

    int accumulated = 0;
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final stepEnd = accumulated + step.durationSeconds;

      if (elapsedSeconds < stepEnd) {
        // Check if we should interpolate to next step
        if (i < steps.length - 1) {
          final nextFreq = steps[i + 1].frequency;
          // Smooth interpolation in last 30 seconds of step
          final transitionStart = step.durationSeconds - 30;
          if (elapsedSeconds - accumulated > transitionStart) {
            final transitionProgress =
                (elapsedSeconds - accumulated - transitionStart) / 30.0;
            return step.frequency +
                (nextFreq - step.frequency) * transitionProgress;
          }
        }
        return step.frequency;
      }
      accumulated = stepEnd;
    }
    return steps.last.frequency;
  }
}

// =============================================================================
// PRE-BUILT PROTOCOLS
// =============================================================================

/// Library of pre-built therapeutic protocols
class ProtocolLibrary {
  /// Focus Protocol (45 minutes)
  /// Alpha → Low Beta → Gamma → Alpha
  static const focusProtocol = TherapeuticProtocol(
    id: 'focus_45',
    name: 'Deep Focus',
    description:
        'Enhances concentration and cognitive performance for work or study',
    bpm: 80,
    includeLoFiTextures: true,
    targetStates: [
      BrainwaveState.alpha,
      BrainwaveState.lowBeta,
      BrainwaveState.gamma,
    ],
    steps: [
      // Centering phase
      FrequencyStep(
        frequency: 10.0,
        durationSeconds: 300, // 5 min
        purpose: 'Centering and relaxation',
      ),
      // Building focus
      FrequencyStep(
        frequency: 14.0,
        durationSeconds: 600, // 10 min
        purpose: 'Building focused attention (SMR)',
      ),
      // Peak cognition
      FrequencyStep(
        frequency: 40.0,
        durationSeconds: 1500, // 25 min
        purpose: 'Peak cognitive performance (Gamma)',
      ),
      // Return to baseline
      FrequencyStep(
        frequency: 10.0,
        durationSeconds: 300, // 5 min
        purpose: 'Gentle return to baseline',
      ),
    ],
  );

  /// Sleep Protocol (30 minutes)
  /// Alpha → Theta → Delta
  static const sleepProtocol = TherapeuticProtocol(
    id: 'sleep_30',
    name: 'Deep Sleep',
    description: 'Guides you into deep restorative sleep',
    bpm: 60,
    includeLoFiTextures: true,
    targetStates: [
      BrainwaveState.alpha,
      BrainwaveState.theta,
      BrainwaveState.delta,
    ],
    steps: [
      FrequencyStep(
        frequency: 10.0,
        durationSeconds: 180, // 3 min
        purpose: 'Initial relaxation',
      ),
      FrequencyStep(
        frequency: 8.0,
        durationSeconds: 120, // 2 min
        purpose: 'Deepening relaxation',
      ),
      FrequencyStep(
        frequency: 6.0,
        durationSeconds: 300, // 5 min
        purpose: 'Theta meditation state',
      ),
      FrequencyStep(
        frequency: 4.0,
        durationSeconds: 300, // 5 min
        purpose: 'Hypnagogic transition',
      ),
      FrequencyStep(
        frequency: 2.0,
        durationSeconds: 600, // 10 min
        purpose: 'Deep delta sleep',
        volumeMultiplier: 0.7,
      ),
      FrequencyStep(
        frequency: 0.5,
        durationSeconds: 300, // 5 min
        purpose: 'Deepest sleep state',
        volumeMultiplier: 0.5,
      ),
    ],
  );

  /// Meditation Protocol (20 minutes)
  /// Schumann → Shamanic → Inner guidance
  static const meditationProtocol = TherapeuticProtocol(
    id: 'meditation_20',
    name: 'Deep Meditation',
    description: 'Facilitates deep meditative states and inner exploration',
    bpm: 70,
    includeLoFiTextures: true,
    targetStates: [BrainwaveState.theta, BrainwaveState.alpha],
    steps: [
      FrequencyStep(
        frequency: SchumannResonance.primary, // 7.83 Hz
        durationSeconds: 420, // 7 min
        purpose: 'Earth grounding (Schumann Resonance)',
      ),
      FrequencyStep(
        frequency: 4.5,
        durationSeconds: 480, // 8 min
        purpose: 'Shamanic consciousness',
      ),
      FrequencyStep(
        frequency: 7.5,
        durationSeconds: 300, // 5 min
        purpose: 'Inner guidance and insight',
      ),
    ],
  );

  /// Chakra Alignment Protocol (28 minutes)
  /// Root → Crown sequence
  static TherapeuticProtocol get chakraProtocol => TherapeuticProtocol(
        id: 'chakra_28',
        name: 'Chakra Alignment',
        description: 'Balances and aligns all seven chakras',
        bpm: 75,
        includeLoFiTextures: false, // Pure tones for chakra work
        targetStates: [BrainwaveState.alpha, BrainwaveState.theta],
        steps: Chakra.values
            .map((chakra) => FrequencyStep(
                  frequency: chakra.frequency,
                  durationSeconds: 240, // 4 min each
                  purpose: '${chakra.sanskritName} (${chakra.description})',
                ))
            .toList(),
      );

  /// Anxiety Relief Protocol (15 minutes)
  static const anxietyReliefProtocol = TherapeuticProtocol(
    id: 'anxiety_15',
    name: 'Anxiety Relief',
    description: 'Calms the nervous system and reduces anxiety',
    bpm: 60,
    includeLoFiTextures: true,
    targetStates: [BrainwaveState.alpha, BrainwaveState.theta],
    steps: [
      FrequencyStep(
        frequency: 10.0,
        durationSeconds: 180, // 3 min
        purpose: 'Serotonin release, mood elevation',
      ),
      FrequencyStep(
        frequency: 8.0,
        durationSeconds: 240, // 4 min
        purpose: 'Stress reduction',
      ),
      FrequencyStep(
        frequency: SchumannResonance.primary,
        durationSeconds: 300, // 5 min
        purpose: 'Earth grounding, stability',
      ),
      FrequencyStep(
        frequency: 10.0,
        durationSeconds: 180, // 3 min
        purpose: 'Return to calm alertness',
      ),
    ],
  );

  /// Creativity Boost Protocol (25 minutes)
  static const creativityProtocol = TherapeuticProtocol(
    id: 'creativity_25',
    name: 'Creative Flow',
    description: 'Unlocks creative potential and imagination',
    bpm: 75,
    includeLoFiTextures: true,
    targetStates: [BrainwaveState.alpha, BrainwaveState.theta],
    steps: [
      FrequencyStep(
        frequency: 10.0,
        durationSeconds: 300, // 5 min
        purpose: 'Relaxed alertness',
      ),
      FrequencyStep(
        frequency: 7.5,
        durationSeconds: 600, // 10 min
        purpose: 'Creative visualization (Theta border)',
      ),
      FrequencyStep(
        frequency: 6.0,
        durationSeconds: 420, // 7 min
        purpose: 'Deep creative access',
      ),
      FrequencyStep(
        frequency: 10.0,
        durationSeconds: 180, // 3 min
        purpose: 'Integration and return',
      ),
    ],
  );

  /// Get all available protocols
  static List<TherapeuticProtocol> get allProtocols => [
        focusProtocol,
        sleepProtocol,
        meditationProtocol,
        chakraProtocol,
        anxietyReliefProtocol,
        creativityProtocol,
      ];

  /// Get protocol by ID
  static TherapeuticProtocol? getById(String id) {
    try {
      return allProtocols.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

// =============================================================================
// SPECIAL FREQUENCIES (FROM FREQUENCIES.MD)
// =============================================================================

/// Special therapeutic frequencies with documented effects
class SpecialFrequencies {
  /// 0.5 Hz - Pain relief, lower back pain
  static const double painRelief = 0.5;

  /// 1.0 Hz - Pituitary stimulation, growth hormone
  static const double growthHormone = 1.0;

  /// 1.5 Hz - Universal healing rate (Abrahams)
  static const double universalHealing = 1.5;

  /// 2.5 Hz - Endorphin production, sedative
  static const double endorphinRelease = 2.5;

  /// 3.5 Hz - DNA stimulation, depression/anxiety remedy
  static const double dnaStimulation = 3.5;

  /// 5.0 Hz - Unusual problem solving, pain relief
  static const double problemSolving = 5.0;

  /// 6.0 Hz - Long term memory stimulation
  static const double memoryStimulation = 6.0;

  /// 7.83 Hz - Schumann Resonance
  static const double schumann = 7.83;

  /// 10.0 Hz - Serotonin release, universal beneficial
  static const double serotonin = 10.0;

  /// 10.5 Hz - Body healing, mind/body unity
  static const double bodyHealing = 10.5;

  /// 12.0 Hz - Mental stability, centering
  static const double mentalStability = 12.0;

  /// 14.0 Hz - Alertness, IQ enhancement
  static const double alertness = 14.0;

  /// 15.0 Hz - Chronic pain
  static const double chronicPain = 15.0;

  /// 20.0 Hz - Pineal stimulation, fatigue energize
  static const double pinealStimulation = 20.0;

  /// 40.0 Hz - Gamma binding, peak cognition
  static const double gammaCognition = 40.0;

  /// 111 Hz - Beta endorphins, cell regeneration
  static const double cellRegeneration = 111.0;

  /// 528 Hz - DNA repair (Solfeggio MI)
  static const double dnaRepair = 528.0;
}
