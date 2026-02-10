import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AmbientSoundType {
  none,
  rain,
  ocean,
  forest,
  whiteNoise,
  fireplace,
}

class AmbientSound {
  final AmbientSoundType type;
  final String name;
  final String icon;
  final String? assetPath;

  const AmbientSound({
    required this.type,
    required this.name,
    required this.icon,
    this.assetPath,
  });
}

class AmbientSoundService {
  static final AmbientSoundService _instance = AmbientSoundService._internal();
  factory AmbientSoundService() => _instance;
  AmbientSoundService._internal();

  AudioPlayer? _audioPlayer;

  AmbientSoundType _currentSound = AmbientSoundType.none;
  double _volume = 0.5;
  bool _isPlaying = false;

  static const List<AmbientSound> availableSounds = [
    AmbientSound(
      type: AmbientSoundType.none,
      name: 'None',
      icon: '🔇',
    ),
    AmbientSound(
      type: AmbientSoundType.rain,
      name: 'Rain',
      icon: '🌧️',
      assetPath: 'assets/audio/rain.mp3',
    ),
    AmbientSound(
      type: AmbientSoundType.ocean,
      name: 'Ocean',
      icon: '🌊',
      assetPath: 'assets/audio/ocean.mp3',
    ),
    AmbientSound(
      type: AmbientSoundType.forest,
      name: 'Forest',
      icon: '🌲',
      assetPath: 'assets/audio/forest.mp3',
    ),
    AmbientSound(
      type: AmbientSoundType.whiteNoise,
      name: 'White Noise',
      icon: '📻',
      // Placeholder - no audio file yet
    ),
    AmbientSound(
      type: AmbientSoundType.fireplace,
      name: 'Fireplace',
      icon: '🔥',
      // Placeholder - no audio file yet
    ),
  ];

  AmbientSoundType get currentSound => _currentSound;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  Future<void> play(AmbientSoundType soundType) async {
    await stop();

    if (soundType == AmbientSoundType.none) {
      _currentSound = soundType;
      return;
    }

    _currentSound = soundType;

    if (soundType == AmbientSoundType.whiteNoise || 
        soundType == AmbientSoundType.fireplace) {
      debugPrint('AmbientSoundService: $soundType not implemented yet');
      _isPlaying = false;
      return;
    }

    await _playLocalAudio(soundType);
  }

  Future<void> _playLocalAudio(AmbientSoundType soundType) async {
    final sound = availableSounds.firstWhere((s) => s.type == soundType);
    if (sound.assetPath == null) {
      debugPrint('AmbientSoundService: No asset path for $soundType');
      return;
    }

    try {
      debugPrint('AmbientSoundService: Playing ${sound.assetPath}');
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer!.setVolume(_volume);
      
      // Use AssetSource for local files
      await _audioPlayer!.play(AssetSource(sound.assetPath!.replaceFirst('assets/', '')));
      
      _isPlaying = true;
      debugPrint('AmbientSoundService: Successfully started playing $soundType');
    } catch (e) {
      debugPrint('AmbientSoundService: Error playing audio: $e');
      _isPlaying = false;
    }
  }

  Future<void> pause() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.pause();
    }
    _isPlaying = false;
  }

  Future<void> resume() async {
    if (_currentSound == AmbientSoundType.none) return;

    if (_audioPlayer != null) {
      await _audioPlayer!.resume();
      _isPlaying = true;
    }
  }

  Future<void> stop() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }

    _isPlaying = false;
    _currentSound = AmbientSoundType.none;
  }

  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);

    if (_audioPlayer != null) {
      await _audioPlayer!.setVolume(_volume);
    }
  }

  void dispose() {
    stop();
  }
}
