library advanced_hypnotic_audio_service;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mindflow_ai_coach/core/audio/ai_music_generator.dart';
import 'package:mindflow_ai_coach/core/audio/frequency_protocols.dart';

class AdvancedHypnoticAudioService {
  static final AdvancedHypnoticAudioService _instance =
      AdvancedHypnoticAudioService._internal();
  factory AdvancedHypnoticAudioService() => _instance;
  AdvancedHypnoticAudioService._internal();

  final AIMusicGenerator _musicGenerator = AIMusicGenerator();
  MusicSession? _currentSession;
  bool _isPlaying = false;
  double _volume = 0.7;

  final StreamController<MusicSessionState> _stateController =
      StreamController<MusicSessionState>.broadcast();

  Stream<MusicSessionState> get stateStream => _stateController.stream;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  MusicSession? get currentSession => _currentSession;

  Future<void> startProtocol(TherapeuticProtocol protocol,
      {double volume = 0.7}) async {
    debugPrint('AdvancedHypnoticAudio: startProtocol stub called - ${protocol.name}');
    
    // Stub implementation for mobile
    _currentSession = await _musicGenerator.startSession(
      protocol: protocol,
      volume: volume,
    );

    _volume = volume;
    _isPlaying = true;

    // Simulate session updates for UI
    _currentSession!.addListener((state) {
      _stateController.add(state);
    });
  }

  Future<void> startForGoal(String goal, {double volume = 0.7}) async {
    final protocol = _musicGenerator.selectProtocolForGoal(goal);
    await startProtocol(protocol, volume: volume);
  }

  Future<void> startDeepFocus({double volume = 0.7}) async {
    await startProtocol(ProtocolLibrary.focusProtocol, volume: volume);
  }

  Future<void> startDeepSleep({double volume = 0.7}) async {
    await startProtocol(ProtocolLibrary.sleepProtocol, volume: volume);
  }

  Future<void> startMeditation({double volume = 0.7}) async {
    await startProtocol(ProtocolLibrary.meditationProtocol, volume: volume);
  }

  Future<void> startAnxietyRelief({double volume = 0.7}) async {
    await startProtocol(ProtocolLibrary.anxietyReliefProtocol, volume: volume);
  }

  Future<void> startCreativity({double volume = 0.7}) async {
    await startProtocol(ProtocolLibrary.creativityProtocol, volume: volume);
  }

  Future<void> startChakraAlignment({double volume = 0.7, int minutesPerChakra = 4}) async {
    debugPrint('AdvancedHypnoticAudio: startChakraAlignment stub called');
    _isPlaying = true;
  }

  void playSchumannResonance({int harmonic = 0, double volume = 0.6}) {
    debugPrint('AdvancedHypnoticAudio: playSchumannResonance stub called');
    _isPlaying = true;
  }

  void playSolfeggio(SolfeggioFrequency frequency, {double volume = 0.5}) {
    debugPrint('AdvancedHypnoticAudio: playSolfeggio stub called');
    _isPlaying = true;
  }

  void playLoFiChords({String progression = 'lofi', double volume = 0.2}) {
    debugPrint('AdvancedHypnoticAudio: playLoFiChords stub called');
  }

  void stop() {
    _currentSession?.stop();
    _currentSession = null;
    _isPlaying = false;
    debugPrint('AdvancedHypnoticAudio: Stop stub called');
  }

  void pause() {
    _currentSession?.pause();
    debugPrint('AdvancedHypnoticAudio: Pause stub called');
  }

  void resume() {
    _currentSession?.resume();
    debugPrint('AdvancedHypnoticAudio: Resume stub called');
  }

  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    _currentSession?.setVolume(_volume);
  }

  void transitionToFrequency(double frequency, {int durationMs = 3000}) {
    debugPrint('AdvancedHypnoticAudio: transitionToFrequency stub called ($frequency Hz)');
  }

  void dispose() {
    stop();
    _stateController.close();
  }
}

extension QuickProtocols on AdvancedHypnoticAudioService {
  List<TherapeuticProtocol> get allProtocols => ProtocolLibrary.allProtocols;

  List<String> get protocolNames =>
      allProtocols.map((p) => p.name).toList();

  Future<void> startProtocolByName(String name, {double volume = 0.7}) async {
    final protocol = allProtocols.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
      orElse: () => ProtocolLibrary.meditationProtocol,
    );
    await startProtocol(protocol, volume: volume);
  }
}

