/// **AI Music Generator Engine**
///
/// The intelligence layer that selects and combines frequencies based on
/// user goals, behavioral profile, and time of day.
///
/// **Core Features:**
/// - Goal-to-protocol mapping (NLP intent analysis)
/// - Custom protocol builder (user-selected frequencies)
/// - Circadian optimization (time-of-day adjustments)
/// - Smooth frequency transitions
/// - Session state management
library ai_music_generator;

import 'dart:async';
// Core imports handled by other packages
import 'package:flutter/foundation.dart';
import 'frequency_protocols.dart';

// =============================================================================
// AI MUSIC GENERATOR SERVICE
// =============================================================================

/// AI-powered therapeutic music generator
class AIMusicGenerator {
  static final AIMusicGenerator _instance = AIMusicGenerator._internal();
  factory AIMusicGenerator() => _instance;
  AIMusicGenerator._internal();

  /// Current active session
  MusicSession? _currentSession;

  /// Get current session if any
  MusicSession? get currentSession => _currentSession;

  /// Whether a session is currently active
  bool get isPlaying => _currentSession?.isActive ?? false;

  /// Current frequency being played
  double get currentFrequency => _currentSession?.currentFrequency ?? 0;

  // ===========================================================================
  // GOAL-BASED PROTOCOL SELECTION (AI)
  // ===========================================================================

  /// Analyzes user goal and returns optimal therapeutic protocol
  ///
  /// Example goals:
  /// - "I want to focus"
  /// - "Help me sleep"
  /// - "I need to relax"
  /// - "Boost my creativity"
  TherapeuticProtocol selectProtocolForGoal(String userGoal) {
    final goal = userGoal.toLowerCase();

    // Focus/Concentration keywords
    if (_matchesAny(goal, [
      'focus',
      'concentrate',
      'study',
      'work',
      'productive',
      'attention',
      'learn',
    ])) {
      return ProtocolLibrary.focusProtocol;
    }

    // Sleep keywords
    if (_matchesAny(goal, [
      'sleep',
      'insomnia',
      'rest',
      'tired',
      'exhausted',
      'bedtime',
      'nap',
    ])) {
      return ProtocolLibrary.sleepProtocol;
    }

    // Meditation/Mindfulness keywords
    if (_matchesAny(goal, [
      'meditat',
      'mindful',
      'spiritual',
      'zen',
      'inner peace',
      'contemplat',
    ])) {
      return ProtocolLibrary.meditationProtocol;
    }

    // Anxiety/Stress keywords
    if (_matchesAny(goal, [
      'anxious',
      'anxiety',
      'stress',
      'worried',
      'nervous',
      'panic',
      'calm',
      'relax',
    ])) {
      return ProtocolLibrary.anxietyReliefProtocol;
    }

    // Creativity keywords
    if (_matchesAny(goal, [
      'creat',
      'imagin',
      'inspir',
      'ideas',
      'brainstorm',
      'art',
      'write',
      'compose',
    ])) {
      return ProtocolLibrary.creativityProtocol;
    }

    // Energy/Chakra keywords
    if (_matchesAny(goal, [
      'chakra',
      'energy',
      'align',
      'balance',
      'heal',
      'spiritual',
    ])) {
      return ProtocolLibrary.chakraProtocol;
    }

    // Default to meditation if no match
    return ProtocolLibrary.meditationProtocol;
  }

  /// Check if goal matches any keywords
  bool _matchesAny(String goal, List<String> keywords) {
    return keywords.any((keyword) => goal.contains(keyword));
  }

  // ===========================================================================
  // CIRCADIAN OPTIMIZATION
  // ===========================================================================

  /// Adjusts protocol parameters based on time of day
  TherapeuticProtocol optimizeForTimeOfDay(
    TherapeuticProtocol protocol,
    DateTime time,
  ) {
    final hour = time.hour;

    // Morning (6-10): Higher energy, faster BPM
    if (hour >= 6 && hour < 10) {
      return _adjustBPM(protocol, 85);
    }

    // Midday (10-14): Peak alertness
    if (hour >= 10 && hour < 14) {
      return _adjustBPM(protocol, 80);
    }

    // Afternoon (14-18): Slight slowdown
    if (hour >= 14 && hour < 18) {
      return _adjustBPM(protocol, 75);
    }

    // Evening (18-22): Wind down
    if (hour >= 18 && hour < 22) {
      return _adjustBPM(protocol, 70);
    }

    // Night (22-6): Sleep preparation
    return _adjustBPM(protocol, 60);
  }

  /// Creates new protocol with adjusted BPM
  TherapeuticProtocol _adjustBPM(TherapeuticProtocol protocol, int newBPM) {
    return TherapeuticProtocol(
      id: protocol.id,
      name: protocol.name,
      description: protocol.description,
      steps: protocol.steps,
      bpm: newBPM,
      includeLoFiTextures: protocol.includeLoFiTextures,
      targetStates: protocol.targetStates,
    );
  }

  // ===========================================================================
  // CUSTOM PROTOCOL BUILDER
  // ===========================================================================

  /// Builds a custom protocol from user-selected frequencies
  ///
  /// [frequencies] - List of frequency specifications
  /// [totalDurationMinutes] - Total session duration
  /// [transitionStyle] - How to transition between frequencies
  TherapeuticProtocol buildCustomProtocol({
    required List<CustomFrequencySpec> frequencies,
    required int totalDurationMinutes,
    TransitionStyle transitionStyle = TransitionStyle.smooth,
    int? bpm,
    bool includeLoFiTextures = true,
  }) {
    if (frequencies.isEmpty) {
      throw ArgumentError('At least one frequency must be specified');
    }

    final totalSeconds = totalDurationMinutes * 60;
    final stepDuration = totalSeconds ~/ frequencies.length;

    final steps = frequencies.map((spec) {
      return FrequencyStep(
        frequency: spec.frequency,
        durationSeconds: stepDuration,
        purpose: spec.purpose ?? _describFrequency(spec.frequency),
        volumeMultiplier: spec.volumeMultiplier,
      );
    }).toList();

    return TherapeuticProtocol(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Custom Protocol',
      description: 'User-created frequency sequence',
      steps: steps,
      bpm: bpm ?? 75,
      includeLoFiTextures: includeLoFiTextures,
      targetStates: _inferTargetStates(frequencies),
    );
  }

  /// Generates description for a frequency
  String _describFrequency(double freq) {
    if (freq < 4) return 'Deep delta state';
    if (freq < 8) return 'Theta meditation';
    if (freq < 12) return 'Alpha relaxation';
    if (freq < 15) return 'Low beta focus';
    if (freq < 20) return 'Mid beta alertness';
    if (freq < 30) return 'High beta activation';
    if (freq < 50) return 'Gamma cognition';
    if (freq < 300) return 'Sub-bass therapeutic tone';
    if (freq < 500) return 'Chakra alignment tone';
    return 'Healing frequency tone';
  }

  /// Infers target brainwave states from frequencies
  List<BrainwaveState> _inferTargetStates(
      List<CustomFrequencySpec> frequencies) {
    final states = <BrainwaveState>{};

    for (final spec in frequencies) {
      final freq = spec.frequency;
      if (freq < 4)
        states.add(BrainwaveState.delta);
      else if (freq < 8)
        states.add(BrainwaveState.theta);
      else if (freq < 12)
        states.add(BrainwaveState.alpha);
      else if (freq < 15)
        states.add(BrainwaveState.lowBeta);
      else if (freq < 20)
        states.add(BrainwaveState.midBeta);
      else if (freq < 30)
        states.add(BrainwaveState.highBeta);
      else
        states.add(BrainwaveState.gamma);
    }

    return states.toList();
  }

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

  /// Starts a music generation session
  ///
  /// Returns a [MusicSession] that can be used to control playback
  Future<MusicSession> startSession({
    required TherapeuticProtocol protocol,
    double volume = 0.7,
    bool optimizeForTime = true,
  }) async {
    // Stop any existing session
    await stopSession();

    // Apply circadian optimization if enabled
    final optimizedProtocol = optimizeForTime
        ? optimizeForTimeOfDay(protocol, DateTime.now())
        : protocol;

    _currentSession = MusicSession(
      protocol: optimizedProtocol,
      volume: volume,
      startTime: DateTime.now(),
    );

    debugPrint(
        '🎵 AI Music Generator: Starting ${optimizedProtocol.name} session');

    return _currentSession!;
  }

  /// Starts a session based on user goal
  Future<MusicSession> startSessionForGoal({
    required String goal,
    double volume = 0.7,
  }) async {
    final protocol = selectProtocolForGoal(goal);
    return startSession(protocol: protocol, volume: volume);
  }

  /// Stops the current session
  Future<void> stopSession() async {
    if (_currentSession != null) {
      await _currentSession!.stop();
      _currentSession = null;
      debugPrint('🛑 AI Music Generator: Session stopped');
    }
  }

  /// Pauses the current session
  void pauseSession() {
    _currentSession?.pause();
  }

  /// Resumes the current session
  void resumeSession() {
    _currentSession?.resume();
  }

  /// Sets volume for current session
  void setVolume(double volume) {
    _currentSession?.setVolume(volume);
  }
}

// =============================================================================
// MUSIC SESSION
// =============================================================================

/// Represents an active music generation session
class MusicSession {
  /// The protocol being played
  final TherapeuticProtocol protocol;

  /// Current volume (0.0 - 1.0)
  double volume;

  /// When the session started
  final DateTime startTime;

  /// Whether the session is currently playing
  bool _isPlaying = true;

  /// Whether the session is paused
  bool _isPaused = false;

  /// Session update timer
  Timer? _updateTimer;

  /// Listeners for session state changes
  final List<void Function(MusicSessionState)> _listeners = [];

  MusicSession({
    required this.protocol,
    required this.volume,
    required this.startTime,
  }) {
    _startUpdateTimer();
  }

  /// Whether session is active (playing or paused)
  bool get isActive => _isPlaying;

  /// Whether session is paused
  bool get isPaused => _isPaused;

  /// Elapsed time since session start
  Duration get elapsed => DateTime.now().difference(startTime);

  /// Elapsed seconds
  int get elapsedSeconds => elapsed.inSeconds;

  /// Remaining time in session
  Duration get remaining =>
      Duration(seconds: protocol.totalDurationSeconds - elapsedSeconds);

  /// Progress (0.0 - 1.0)
  double get progress =>
      (elapsedSeconds / protocol.totalDurationSeconds).clamp(0.0, 1.0);

  /// Current frequency being played
  double get currentFrequency => protocol.getFrequencyAt(elapsedSeconds);

  /// Current step in the protocol
  FrequencyStep? get currentStep => protocol.getStepAt(elapsedSeconds);

  /// Add a listener for state changes
  void addListener(void Function(MusicSessionState) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(void Function(MusicSessionState) listener) {
    _listeners.remove(listener);
  }

  /// Start the update timer
  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && _isPlaying) {
        _notifyListeners();

        // Check if session is complete
        if (elapsedSeconds >= protocol.totalDurationSeconds) {
          stop();
        }
      }
    });
  }

  /// Notify all listeners of state change
  void _notifyListeners() {
    final state = MusicSessionState(
      isPlaying: _isPlaying,
      isPaused: _isPaused,
      currentFrequency: currentFrequency,
      currentStep: currentStep,
      progress: progress,
      elapsed: elapsed,
      remaining: remaining,
      volume: volume,
    );

    for (final listener in _listeners) {
      listener(state);
    }
  }

  /// Pause the session
  void pause() {
    _isPaused = true;
    _notifyListeners();
    debugPrint(
        '⏸️ Session paused at ${currentFrequency.toStringAsFixed(1)} Hz');
  }

  /// Resume the session
  void resume() {
    _isPaused = false;
    _notifyListeners();
    debugPrint('▶️ Session resumed');
  }

  /// Set volume
  void setVolume(double newVolume) {
    volume = newVolume.clamp(0.0, 1.0);
    _notifyListeners();
  }

  /// Stop the session
  Future<void> stop() async {
    _isPlaying = false;
    _updateTimer?.cancel();
    _notifyListeners();
    debugPrint('🛑 Session stopped after ${elapsed.inMinutes} minutes');
  }

  /// Dispose resources
  void dispose() {
    _updateTimer?.cancel();
    _listeners.clear();
  }
}

/// State of a music session at a point in time
class MusicSessionState {
  final bool isPlaying;
  final bool isPaused;
  final double currentFrequency;
  final FrequencyStep? currentStep;
  final double progress;
  final Duration elapsed;
  final Duration remaining;
  final double volume;

  const MusicSessionState({
    required this.isPlaying,
    required this.isPaused,
    required this.currentFrequency,
    required this.currentStep,
    required this.progress,
    required this.elapsed,
    required this.remaining,
    required this.volume,
  });
}

// =============================================================================
// CUSTOM PROTOCOL TYPES
// =============================================================================

/// Specification for a custom frequency in a user-built protocol
class CustomFrequencySpec {
  /// Target frequency in Hz
  final double frequency;

  /// Optional description/purpose
  final String? purpose;

  /// Volume multiplier (0.0 - 1.0)
  final double volumeMultiplier;

  const CustomFrequencySpec({
    required this.frequency,
    this.purpose,
    this.volumeMultiplier = 1.0,
  });

  /// Create from a brainwave state
  factory CustomFrequencySpec.fromBrainwave(BrainwaveState state) {
    return CustomFrequencySpec(
      frequency: state.optimalFrequency,
      purpose: state.description,
    );
  }

  /// Create from Schumann harmonic
  factory CustomFrequencySpec.fromSchumann(int harmonicIndex) {
    return CustomFrequencySpec(
      frequency: SchumannResonance.harmonics[harmonicIndex],
      purpose: SchumannResonance.getDescription(harmonicIndex),
    );
  }

  /// Create from chakra
  factory CustomFrequencySpec.fromChakra(Chakra chakra) {
    return CustomFrequencySpec(
      frequency: chakra.frequency,
      purpose: '${chakra.sanskritName}: ${chakra.description}',
    );
  }

  /// Create from Solfeggio frequency
  factory CustomFrequencySpec.fromSolfeggio(SolfeggioFrequency solfeggio) {
    return CustomFrequencySpec(
      frequency: solfeggio.frequency,
      purpose: '${solfeggio.note}: ${solfeggio.description}',
    );
  }
}

/// How to transition between frequencies in a custom protocol
enum TransitionStyle {
  /// Instant jump to new frequency
  instant,

  /// Smooth linear transition
  smooth,

  /// Gradual crossfade
  crossfade,
}

// =============================================================================
// FREQUENCY PRESETS (QUICK ACCESS)
// =============================================================================

/// Quick-access frequency presets for common use cases
class FrequencyPresets {
  /// Schumann Resonance - Earth grounding
  static const schumann = CustomFrequencySpec(
    frequency: SchumannResonance.primary,
    purpose: 'Earth grounding, stress relief',
  );

  /// 10 Hz Alpha - Serotonin, universal beneficial
  static const alpha10 = CustomFrequencySpec(
    frequency: SpecialFrequencies.serotonin,
    purpose: 'Serotonin release, mood elevation',
  );

  /// 40 Hz Gamma - Peak cognition
  static const gamma40 = CustomFrequencySpec(
    frequency: SpecialFrequencies.gammaCognition,
    purpose: 'Peak cognitive performance',
  );

  /// 528 Hz - DNA repair
  static const dnaRepair = CustomFrequencySpec(
    frequency: SpecialFrequencies.dnaRepair,
    purpose: 'DNA repair, transformation',
  );

  /// 2.5 Hz Delta - Endorphin release
  static const endorphins = CustomFrequencySpec(
    frequency: SpecialFrequencies.endorphinRelease,
    purpose: 'Endorphin release, pain relief',
  );

  /// 6 Hz Theta - Long term memory
  static const memory = CustomFrequencySpec(
    frequency: SpecialFrequencies.memoryStimulation,
    purpose: 'Long term memory stimulation',
  );
}
