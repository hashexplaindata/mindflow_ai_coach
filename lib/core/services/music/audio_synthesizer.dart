import 'dart:math';
import 'dart:typed_data';

/// Generates raw audio data (WAV format) for specific frequencies and musical patterns.
class AudioSynthesizer {
  static const int sampleRate = 44100;
  static const int bitDepth = 16;
  static const int channels = 2; // Stereo for Binaural Beats

  /// Generates a WAV file buffer containing a binaural beat session
  /// overlaid with a generative ambient musical pad.
  ///
  /// [baseFrequencyHz] - The carrier tone (e.g., 200 Hz).
  /// [beatFrequencyHz] - The target brainwave state (e.g., 10 Hz Alpha).
  /// [durationSeconds] - Length of the audio.
  Uint8List generateSession({
    required double baseFrequencyHz,
    required double beatFrequencyHz,
    required int durationSeconds,
  }) {
    final numSamples = sampleRate * durationSeconds;
    final bufferSize = numSamples * channels * (bitDepth ~/ 8);
    final buffer = Uint8List(44 + bufferSize);
    final byteData = ByteData.view(buffer.buffer);

    // --- WAV HEADER ---
    _writeWavHeader(byteData, bufferSize);

    // --- AUDIO GENERATION ---
    int offset = 44;
    const maxAmplitude = 32767 * 0.8; // 80% volume to avoid clipping

    // Musical Harmonics (Major Pentatonic-ish ambient pad)
    // We add harmonics at 1.5x (Perfect Fifth), 2.0x (Octave), 1.25x (Major Third)
    final harmonics = [
      _Harmonic(multiplier: 1.5, volume: 0.15, speed: 0.1), // Pad 1
      _Harmonic(multiplier: 2.0, volume: 0.1, speed: 0.05), // Pad 2
      _Harmonic(multiplier: 1.25, volume: 0.1, speed: 0.08), // Pad 3
    ];

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;

      // 1. Binaural Beat Layer (Sine Waves)
      // Left Ear: Base Frequency
      // Right Ear: Base + Beat Frequency
      double leftSignal = sin(2 * pi * baseFrequencyHz * t);
      double rightSignal =
          sin(2 * pi * (baseFrequencyHz + beatFrequencyHz) * t);

      // 2. Generative Ambient Layer (Additive Synthesis with LFOs)
      double ambientL = 0;
      double ambientR = 0;

      for (var h in harmonics) {
        // Slowly oscillating volume (LFO) for "breathing" effect
        double lfo = (sin(2 * pi * h.speed * t) + 1) / 2; // 0.0 to 1.0
        double harmonicFreq = baseFrequencyHz * h.multiplier;

        double harmonicSignal = sin(2 * pi * harmonicFreq * t);

        // Pan the harmonics slightly
        ambientL += harmonicSignal * h.volume * lfo;
        ambientR += harmonicSignal * h.volume * (1 - lfo);
      }

      // Mix layers (Binaural is dominant, Ambient is background)
      double mixL = (leftSignal * 0.6) + ambientL;
      double mixR = (rightSignal * 0.6) + ambientR;

      // Clipping protection
      mixL = mixL.clamp(-1.0, 1.0);
      mixR = mixR.clamp(-1.0, 1.0);

      // Convert to 16-bit integer
      int sampleL = (mixL * maxAmplitude).toInt();
      int sampleR = (mixR * maxAmplitude).toInt();

      byteData.setInt16(offset, sampleL, Endian.little);
      offset += 2;
      byteData.setInt16(offset, sampleR, Endian.little);
      offset += 2;
    }

    return buffer;
  }

  void _writeWavHeader(ByteData byteData, int dataSize) {
    // RIFF chunk
    _writeString(byteData, 0, 'RIFF');
    byteData.setUint32(4, 36 + dataSize, Endian.little);
    _writeString(byteData, 8, 'WAVE');

    // fmt chunk
    _writeString(byteData, 12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little); // PCM chunk size
    byteData.setUint16(20, 1, Endian.little); // Audio format 1 = PCM
    byteData.setUint16(22, channels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * channels * (bitDepth ~/ 8),
        Endian.little); // Byte rate
    byteData.setUint16(
        32, channels * (bitDepth ~/ 8), Endian.little); // Block align
    byteData.setUint16(34, bitDepth, Endian.little);

    // data chunk
    _writeString(byteData, 36, 'data');
    byteData.setUint32(40, dataSize, Endian.little);
  }

  void _writeString(ByteData byteData, int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      byteData.setUint8(offset + i, s.codeUnitAt(i));
    }
  }
}

class _Harmonic {
  final double multiplier;
  final double volume;
  final double speed; // LFO speed in Hz

  _Harmonic(
      {required this.multiplier, required this.volume, required this.speed});
}
