import 'package:flutter/foundation.dart';
import 'package:mindflow_ai_coach/core/services/music/nlp_music_bridge.dart';

enum MusicPlaybackState { idle, playing, paused, generating }

/// The conductor of the AI Music Orchestra.
/// Manages layers of audio:
/// 1. Entrainment Layer (Binaural/Isochronic Tones)
/// 2. Ambient Layer (Nature sounds, noise)
/// 3. Generative Layer (AI composed melodies)
class MusicEngine extends ChangeNotifier {
  MusicPlaybackState _state = MusicPlaybackState.idle;
  AudioPrescription? _currentPrescription;

  // Simulation of volume layers
  double _entrainmentVolume = 0.5;
  final double _ambientVolume = 0.3;
  final double _generativeVolume = 0.4;

  MusicPlaybackState get state => _state;
  AudioPrescription? get currentPrescription => _currentPrescription;
  bool get isPlaying => _state == MusicPlaybackState.playing;

  /// Starts a session based on an NLP prescription.
  Future<void> startSession(AudioPrescription prescription) async {
    if (!prescription.hasPrescription) {
      debugPrint('MusicEngine: No prescription to play.');
      return;
    }

    _state = MusicPlaybackState.generating;
    notifyListeners();

    _currentPrescription = prescription;
    debugPrint(
        'MusicEngine: Preparing session for ${prescription.targetFrequency?.label}');
    debugPrint('MusicEngine: Reason: ${prescription.reason}');

    // TODO: Connect to actual Generative AI Model (e.g. MusicGen API or similar)
    // TODO: Initialize Oscillators for Frequency Layer

    // Simulate buffering/generation delay
    await Future.delayed(const Duration(seconds: 1));

    _state = MusicPlaybackState.playing;
    notifyListeners();
    debugPrint('MusicEngine: Playing started.');
  }

  Future<void> stop() async {
    _state = MusicPlaybackState.idle;
    _currentPrescription = null;
    notifyListeners();
    debugPrint('MusicEngine: Stopped.');
  }

  void setEntrainmentVolume(double volume) {
    _entrainmentVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }
}
