import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

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

@JS('window.binauralGenerator.start')
external void _jsStart(JSNumber beatFrequency, JSNumber volume);

@JS('window.binauralGenerator.stop')
external void _jsStop();

@JS('window.binauralGenerator.setVolume')
external void _jsSetVolume(JSNumber volume);

@JS('window.binauralGenerator.pause')
external void _jsPause();

@JS('window.binauralGenerator.resume')
external void _jsResume();

@JS('window.binauralGenerator.getIsPlaying')
external JSBoolean _jsGetIsPlaying();

@JS('window.binauralGenerator.dispose')
external void _jsDispose();

@JS('window.binauralGenerator')
external JSObject? get _jsBinauralGenerator;

class BinauralAudioService {
  static final BinauralAudioService _instance = BinauralAudioService._internal();
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

  bool get _isWebPlatform => kIsWeb;

  bool get _isInitialized {
    if (!_isWebPlatform) return false;
    try {
      return _jsBinauralGenerator != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> startBinauralBeat({
    required BrainwaveType type,
    double volume = 0.3,
  }) async {
    if (!_isWebPlatform) {
      debugPrint('Binaural beats only supported on web platform');
      return;
    }

    if (!_isInitialized) {
      debugPrint('Binaural generator not initialized');
      return;
    }

    if (type == BrainwaveType.none) {
      await stop();
      return;
    }

    final brainwave = availableBrainwaves.firstWhere((b) => b.type == type);
    
    try {
      _jsStart(brainwave.beatFrequency.toJS, volume.toJS);
      _currentType = type;
      _volume = volume;
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error starting binaural beat: $e');
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    if (!_isWebPlatform || !_isInitialized) return;

    try {
      _jsStop();
      _currentType = BrainwaveType.none;
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error stopping binaural beat: $e');
    }
  }

  void setVolume(double newVolume) {
    if (!_isWebPlatform || !_isInitialized) return;

    _volume = newVolume.clamp(0.0, 1.0);
    
    try {
      _jsSetVolume(_volume.toJS);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void pause() {
    if (!_isWebPlatform || !_isInitialized) return;

    try {
      _jsPause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error pausing binaural beat: $e');
    }
  }

  void resume() {
    if (!_isWebPlatform || !_isInitialized) return;
    if (_currentType == BrainwaveType.none) return;

    try {
      _jsResume();
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error resuming binaural beat: $e');
    }
  }

  void fadeIn(Duration duration) {
    setVolume(_volume);
  }

  void fadeOut(Duration duration) {
    setVolume(0);
  }

  void dispose() {
    if (!_isWebPlatform || !_isInitialized) return;

    try {
      _jsDispose();
      _currentType = BrainwaveType.none;
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error disposing binaural generator: $e');
    }
  }
}
