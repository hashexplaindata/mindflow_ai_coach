import 'package:flutter/material.dart';
import 'dart:math' as math;

/// **Hypnotic Audio Volume Slider with Safety Warnings**
///
/// Beautiful, Jobs-inspired volume control with visual feedback
/// for safe listening levels during extended meditation sessions.
///
/// **Safety Zones:**
/// - 🟢 Green (0-30%): Optimal for extended sessions (40+ minutes)
/// - 🟡 Yellow (30-40%): Caution - reduce for long sessions
/// - 🔴 Red (40-50%): Warning - risk of hearing fatigue
/// - ⛔ Max (50%+): BLOCKED - exceeds safe limits

class HypnoticVolumeSlider extends StatefulWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;
  final int sessionDurationMinutes;
  final bool showWarnings;

  const HypnoticVolumeSlider({
    Key? key,
    required this.currentVolume,
    required this.onVolumeChanged,
    this.sessionDurationMinutes = 0,
    this.showWarnings = true,
  }) : super(key: key);

  @override
  State<HypnoticVolumeSlider> createState() => _HypnoticVolumeSliderState();
}

class _HypnoticVolumeSliderState extends State<HypnoticVolumeSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showDetailedWarning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Get safety zone based on volume level
  SafetyZone _getSafetyZone(double volume) {
    if (volume <= 0.30) {
      return SafetyZone.green;
    } else if (volume <= 0.40) {
      return SafetyZone.yellow;
    } else if (volume <= 0.50) {
      return SafetyZone.red;
    } else {
      return SafetyZone.blocked;
    }
  }

  /// Get color for volume level
  Color _getVolumeColor(double volume) {
    final zone = _getSafetyZone(volume);
    switch (zone) {
      case SafetyZone.green:
        return const Color(0xFF8B9D83); // Sage (MindFlow green)
      case SafetyZone.yellow:
        return const Color(0xFFE8B857); // Warm yellow
      case SafetyZone.red:
        return const Color(0xFFE85757); // Soft red
      case SafetyZone.blocked:
        return const Color(0xFFD32F2F); // Alert red
    }
  }

  /// Get warning message for current volume
  String _getWarningMessage(double volume) {
    final zone = _getSafetyZone(volume);
    switch (zone) {
      case SafetyZone.green:
        return 'Optimal volume for extended listening';
      case SafetyZone.yellow:
        return 'Caution: Consider reducing for sessions over 30 minutes';
      case SafetyZone.red:
        return 'Warning: High volume may cause hearing fatigue';
      case SafetyZone.blocked:
        return 'Volume exceeds safe limits';
    }
  }

  /// Get icon for safety zone
  IconData _getZoneIcon(SafetyZone zone) {
    switch (zone) {
      case SafetyZone.green:
        return Icons.check_circle_outline;
      case SafetyZone.yellow:
        return Icons.warning_amber_outlined;
      case SafetyZone.red:
        return Icons.error_outline;
      case SafetyZone.blocked:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zone = _getSafetyZone(widget.currentVolume);
    final color = _getVolumeColor(widget.currentVolume);
    final showWarning = widget.showWarnings && zone != SafetyZone.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Volume percentage display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Volume',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Row(
              children: [
                Text(
                  '${(widget.currentVolume * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _getZoneIcon(zone),
                  size: 20,
                  color: color,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Custom slider with gradient track
        Stack(
          children: [
            // Background gradient track (shows safety zones)
            Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B9D83)
                        .withValues(alpha: 0.3), // Green zone
                    const Color(0xFFE8B857)
                        .withValues(alpha: 0.3), // Yellow zone
                    const Color(0xFFE85757).withValues(alpha: 0.3), // Red zone
                  ],
                  stops: const [0.3, 0.4, 0.5],
                ),
              ),
            ),

            // Slider
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 48,
                thumbShape: _PulsingThumbShape(
                  animation: _pulseController,
                  baseColor: color,
                  shouldPulse: showWarning,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                activeTrackColor: color.withValues(alpha: 0.8),
                inactiveTrackColor: Colors.transparent,
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: math.min(widget.currentVolume, 0.50), // Cap at 50%
                min: 0.0,
                max: 0.50, // Hard limit for safety
                divisions: 50,
                onChanged: (value) {
                  widget.onVolumeChanged(value);

                  // Show detailed warning for first time entering yellow/red
                  if (!_showDetailedWarning && value > 0.30) {
                    setState(() => _showDetailedWarning = true);
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Volume zone labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildZoneLabel('0%', SafetyZone.green),
            _buildZoneLabel('30%', SafetyZone.yellow),
            _buildZoneLabel('50%', SafetyZone.red),
          ],
        ),

        // Warning message
        if (showWarning) ...[
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.15),
                      child: Icon(
                        _getZoneIcon(zone),
                        color: color,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWarningMessage(widget.currentVolume),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: color.withValues(alpha: 0.9),
                        ),
                      ),
                      if (zone == SafetyZone.red &&
                          widget.sessionDurationMinutes > 30) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Prolonged exposure at this level may damage hearing',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Detailed warning for extended sessions
        if (_showDetailedWarning &&
            zone == SafetyZone.red &&
            widget.sessionDurationMinutes >= 40) ...[
          const SizedBox(height: 12),
          Material(
            color: const Color(0xFFFFF3CD), // Soft warning yellow background
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _showHearingProtectionDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hearing,
                      color: Color(0xFF856404),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap to learn about hearing protection →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildZoneLabel(String text, SafetyZone zone) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _getVolumeColor(zone == SafetyZone.green
            ? 0.15
            : zone == SafetyZone.yellow
                ? 0.35
                : 0.45),
      ),
    );
  }

  void _showHearingProtectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.hearing, color: Color(0xFF8B9D83)),
            SizedBox(width: 8),
            Text('Hearing Protection'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Extended exposure to audio above 40% volume can lead to:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildProtectionTip('🔊', 'Temporary hearing fatigue'),
            _buildProtectionTip('⏱️', 'Reduced session effectiveness'),
            _buildProtectionTip('🎧', 'Long-term hearing sensitivity loss'),
            const SizedBox(height: 16),
            const Text(
              'Recommendations:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildProtectionTip('✅', 'Keep volume at 30% or below'),
            _buildProtectionTip('💚', 'Take breaks every 30 minutes'),
            _buildProtectionTip('🎯', 'Binaural beats work at low volumes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onVolumeChanged(0.30); // Set to safe level
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B9D83),
              foregroundColor: Colors.white,
            ),
            child: const Text('Set to 30%'),
          ),
        ],
      ),
    );
  }

  Widget _buildProtectionTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom thumb shape with pulsing animation for warnings
class _PulsingThumbShape extends SliderComponentShape {
  final Animation<double> animation;
  final Color baseColor;
  final bool shouldPulse;

  const _PulsingThumbShape({
    required this.animation,
    required this.baseColor,
    required this.shouldPulse,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Pulsing outer glow (only when warning is active)
    if (shouldPulse) {
      final glowRadius = 16 + (animation.value * 8);
      final glowPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.3 - (animation.value * 0.2))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(center, glowRadius, glowPaint);
    }

    // Main thumb circle
    final thumbPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 12, thumbPaint);

    // Inner white dot
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, innerPaint);
  }
}

/// Safety zone enumeration
enum SafetyZone {
  green, // 0-30% - Optimal
  yellow, // 30-40% - Caution
  red, // 40-50% - Warning
  blocked, // 50%+ - Blocked
}
