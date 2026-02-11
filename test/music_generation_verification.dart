import 'dart:io';
import 'package:mindflow_ai_coach/core/services/music/audio_synthesizer.dart';

void main() {
  print('Initializing MindFlow AI Music Engine...');

  final synth = AudioSynthesizer();

  // Configuration for "Deep Healing & Relaxation"
  // Base: 432 Hz (Universal Healing)
  // Beat: 10 Hz (Alpha State - Calm, Relaxed)
  const baseFreq = 432.0;
  const beatFreq = 10.0;
  const duration = 10; // seconds

  print('Generating Session:');
  print(' - Base Frequency: ${baseFreq}Hz');
  print(' - Target Brainwave: ${beatFreq}Hz (Alpha)');
  print(' - Duration: ${duration}s');
  print(' - Layers: Binaural Beats + Generative Pentatonic Harmonics');

  final wavData = synth.generateSession(
    baseFrequencyHz: baseFreq,
    beatFrequencyHz: beatFreq,
    durationSeconds: duration,
  );

  const filename = 'mindflow_demo.wav';
  final file = File(filename);
  file.writeAsBytesSync(wavData);

  print('Success! Generated audio file: ${file.absolute.path}');
  print('File size: ${(wavData.length / 1024 / 1024).toStringAsFixed(2)} MB');
  print('Please play this file to verify "Music not Noise" capability.');
}
