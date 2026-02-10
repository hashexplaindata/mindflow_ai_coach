import 'dart:async';
import 'package:flutter/foundation.dart';

enum BrainwaveType {
  none,
  delta,
  theta,
  alpha,
  beta,
  gamma,
}

class Brainwave {
  final BrainwaveType type;
  final String name;
  final String description;
  final String icon;
  final double beatFrequency;

  const Brainwave({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.beatFrequency,
  });
}

class BinauralAudioService {
  static final BinauralAudioService _instance =
      BinauralAudioService._internal();
  factory BinauralAudioService() => _instance;
  BinauralAudioService._internal();

  BrainwaveType _currentType = BrainwaveType.none;
  double _volume = 0.3;
  bool _isPlaying = false;

  static const List<Brainwave> availableBrainwaves = [
    Brainwave(
      type: BrainwaveType.none,
      name: 'None',
      description: 'No brainwave entrainment',
      icon: '🔇',
      beatFrequency: 0,
    ),
    Brainwave(
      type: BrainwaveType.delta,
      name: 'Deep Sleep',
      description: 'Delta waves (2Hz) promote deep, restorative sleep',
      icon: '🌙',
      beatFrequency: 2,
    ),
    Brainwave(
      type: BrainwaveType.theta,
      name: 'Meditation',
      description: 'Theta waves (6Hz) enhance meditation & creativity',
      icon: '🧘',
      beatFrequency: 6,
    ),
    Brainwave(
      type: BrainwaveType.alpha,
      name: 'Relaxation',
      description: 'Alpha waves (10Hz) reduce stress & anxiety',
      icon: '🌿',
      beatFrequency: 10,
    ),
    Brainwave(
      type: BrainwaveType.beta,
      name: 'Focus',
      description: 'Beta waves (15Hz) improve concentration & alertness',
      icon: '🎯',
      beatFrequency: 15,
    ),
    Brainwave(
      type: BrainwaveType.gamma,
      name: 'Peak Performance',
      description: 'Gamma waves (40Hz) enhance cognition & memory',
      icon: '⚡',
      beatFrequency: 40,
    ),
  ];

  BrainwaveType get currentType => _currentType;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  Future<void> startBinauralBeat({
    required BrainwaveType type,
    double volume = 0.3,
  }) async {
    debugPrint(
        'BinauralAudioService: startBinauralBeat called - type: $type, volume: $volume');
    debugPrint(
        'BinauralAudioService: Not supported on mobile platform yet');
    
    _currentType = type;
    _volume = volume;
    if (type != BrainwaveType.none) {
      _isPlaying = true;
    } else {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    debugPrint('BinauralAudioService: stop called');
    _currentType = BrainwaveType.none;
    _isPlaying = false;
  }

  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    debugPrint('BinauralAudioService: volume set to $_volume');
  }

  void pause() {
    debugPrint('BinauralAudioService: pause called');
    _isPlaying = false;
  }

  void resume() {
    debugPrint('BinauralAudioService: resume called');
    if (_currentType != BrainwaveType.none) {
      _isPlaying = true;
    }
  }

  void fadeIn(Duration duration) {
    // Stub
  }

  void fadeOut(Duration duration) {
    // Stub
  }

  void dispose() {
    _isPlaying = false;
  }
}
