import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _currentTrack = "Select a Sound";

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String assetPath, String trackName) async {
    try {
      await _audioPlayer.stop(); // Stop previous
      await _audioPlayer.play(AssetSource(assetPath));
      setState(() {
        _isPlaying = true;
        _currentTrack = trackName;
      });
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art / Visual
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withValues(alpha: 0.5),
                      Colors.purpleAccent.withValues(alpha: 0.5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ]),
              child: const Icon(Icons.music_note_rounded,
                  size: 80, color: Colors.white),
            ),
            const SizedBox(height: 40),

            // Title
            const Text(
              "MindFlow Ambience",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Safe default font
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentTrack,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 50),

            // Sound Selectors (The "Hack")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSoundBtn(Icons.water_drop, "Rain", "audio/rain.mp3"),
                _buildSoundBtn(Icons.forest, "Forest", "audio/forest.mp3"),
                _buildSoundBtn(Icons.waves, "Ocean", "audio/ocean.mp3"),
              ],
            ),

            const SizedBox(height: 40),

            // Play/Pause Control
            IconButton(
              iconSize: 64,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white,
              ),
              onPressed: _togglePlay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundBtn(IconData icon, String label, String path) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _playSound(path, label),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
