import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:web_audio';

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
  final String? audioUrl;

  const AmbientSound({
    required this.type,
    required this.name,
    required this.icon,
    this.audioUrl,
  });
}

class AmbientSoundService {
  static final AmbientSoundService _instance = AmbientSoundService._internal();
  factory AmbientSoundService() => _instance;
  AmbientSoundService._internal();

  html.AudioElement? _audioElement;
  AudioContext? _audioContext;
  AudioBufferSourceNode? _noiseSource;
  GainNode? _gainNode;
  
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
      audioUrl: 'https://cdn.pixabay.com/audio/2022/05/13/audio_257112473d.mp3',
    ),
    AmbientSound(
      type: AmbientSoundType.ocean,
      name: 'Ocean',
      icon: '🌊',
      audioUrl: 'https://cdn.pixabay.com/audio/2024/11/21/audio_bc6d6db73e.mp3',
    ),
    AmbientSound(
      type: AmbientSoundType.forest,
      name: 'Forest',
      icon: '🌲',
      audioUrl: 'https://cdn.pixabay.com/audio/2022/03/10/audio_4a84dcc571.mp3',
    ),
    AmbientSound(
      type: AmbientSoundType.whiteNoise,
      name: 'White Noise',
      icon: '📻',
    ),
    AmbientSound(
      type: AmbientSoundType.fireplace,
      name: 'Fireplace',
      icon: '🔥',
      audioUrl: 'https://cdn.pixabay.com/audio/2024/04/17/audio_76e4d07b00.mp3',
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

    if (soundType == AmbientSoundType.whiteNoise) {
      await _playWhiteNoise();
    } else {
      await _playAudioUrl(soundType);
    }
  }

  Future<void> _playAudioUrl(AmbientSoundType soundType) async {
    final sound = availableSounds.firstWhere((s) => s.type == soundType);
    if (sound.audioUrl == null) return;

    _audioElement = html.AudioElement(sound.audioUrl);
    _audioElement!.loop = true;
    _audioElement!.volume = _volume;
    
    try {
      await _audioElement!.play();
      _isPlaying = true;
    } catch (e) {
      print('Error playing audio: $e');
      _isPlaying = false;
    }
  }

  Future<void> _playWhiteNoise() async {
    try {
      _audioContext = AudioContext();
      
      final sampleRate = _audioContext!.sampleRate!.toInt();
      final bufferSize = sampleRate * 2;
      final buffer = _audioContext!.createBuffer(1, bufferSize, sampleRate);
      final channelData = buffer.getChannelData(0);
      
      for (var i = 0; i < bufferSize; i++) {
        channelData[i] = (html.window.crypto!.getRandomValues(Uint8List(1)) as Uint8List)[0] / 128.0 - 1.0;
      }
      
      _gainNode = _audioContext!.createGain();
      _gainNode!.gain!.value = _volume * 0.3;
      _gainNode!.connectNode(_audioContext!.destination!);
      
      _noiseSource = _audioContext!.createBufferSource();
      _noiseSource!.buffer = buffer;
      _noiseSource!.loop = true;
      _noiseSource!.connectNode(_gainNode!);
      _noiseSource!.start(0);
      
      _isPlaying = true;
    } catch (e) {
      print('Error playing white noise: $e');
      _isPlaying = false;
    }
  }

  void pause() {
    if (_audioElement != null) {
      _audioElement!.pause();
    }
    if (_audioContext != null && _audioContext!.state == 'running') {
      _audioContext!.suspend();
    }
    _isPlaying = false;
  }

  void resume() {
    if (_currentSound == AmbientSoundType.none) return;
    
    if (_audioElement != null) {
      _audioElement!.play();
      _isPlaying = true;
    }
    if (_audioContext != null && _audioContext!.state == 'suspended') {
      _audioContext!.resume();
      _isPlaying = true;
    }
  }

  Future<void> stop() async {
    if (_audioElement != null) {
      _audioElement!.pause();
      _audioElement!.currentTime = 0;
      _audioElement = null;
    }
    
    if (_noiseSource != null) {
      try {
        _noiseSource!.stop(0);
      } catch (e) {
      }
      _noiseSource!.disconnect();
      _noiseSource = null;
    }
    
    if (_gainNode != null) {
      _gainNode!.disconnect();
      _gainNode = null;
    }
    
    if (_audioContext != null) {
      await _audioContext!.close();
      _audioContext = null;
    }
    
    _isPlaying = false;
  }

  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    
    if (_audioElement != null) {
      _audioElement!.volume = _volume;
    }
    
    if (_gainNode != null) {
      _gainNode!.gain!.value = _volume * 0.3;
    }
  }

  void dispose() {
    stop();
  }
}
