import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/binaural_audio_service.dart';

class BrainwaveSelector extends StatefulWidget {
  final Function(BrainwaveType)? onBrainwaveChanged;
  final double volume;
  final Function(double)? onVolumeChanged;

  const BrainwaveSelector({
    super.key,
    this.onBrainwaveChanged,
    this.volume = 0.3,
    this.onVolumeChanged,
  });

  @override
  State<BrainwaveSelector> createState() => _BrainwaveSelectorState();
}

class _BrainwaveSelectorState extends State<BrainwaveSelector> {
  final BinauralAudioService _binauralService = BinauralAudioService();
  BrainwaveType _selectedType = BrainwaveType.none;
  late double _volume;
  bool _showVolumeSlider = false;
  bool _showHeadphonesWarning = false;

  @override
  void initState() {
    super.initState();
    _volume = widget.volume;
    _selectedType = _binauralService.currentType;
  }

  void _selectBrainwave(BrainwaveType type) async {
    final wasNone = _selectedType == BrainwaveType.none;

    setState(() {
      _selectedType = type;
      _showVolumeSlider = type != BrainwaveType.none;
      _showHeadphonesWarning = type != BrainwaveType.none && wasNone;
    });

    await _binauralService.startBinauralBeat(
      type: type,
      volume: _volume,
    );
    widget.onBrainwaveChanged?.call(type);

    if (_showHeadphonesWarning) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showHeadphonesWarning = false;
          });
        }
      });
    }
  }

  void _updateVolume(double newVolume) {
    setState(() {
      _volume = newVolume;
    });
    _binauralService.setVolume(newVolume);
    widget.onVolumeChanged?.call(newVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                'Brainwaves',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.jobsSage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.headphones_rounded,
                      size: 12,
                      color: AppColors.jobsSage,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Headphones',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.jobsSage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showHeadphonesWarning ? 40 : 0,
          child: _showHeadphonesWarning
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentYellow.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.headphones_rounded,
                        size: 16,
                        color: AppColors.warningAmber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Use headphones for binaural beats to work',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                AppColors.jobsObsidian.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: BinauralAudioService.availableBrainwaves.length,
            itemBuilder: (context, index) {
              final brainwave = BinauralAudioService.availableBrainwaves[index];
              final isSelected = _selectedType == brainwave.type;

              return Padding(
                padding: EdgeInsets.only(
                  right: index <
                          BinauralAudioService.availableBrainwaves.length - 1
                      ? AppSpacing.spacing12
                      : 0,
                ),
                child: GestureDetector(
                  onTap: () => _selectBrainwave(brainwave.type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.jobsSage.withValues(alpha: 0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.jobsSage
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.jobsSage.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (brainwave.type != BrainwaveType.none && isSelected)
                          _WaveAnimation(
                            frequency: brainwave.beatFrequency,
                            isPlaying: isSelected,
                          )
                        else
                          Text(
                            brainwave.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          brainwave.name,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.jobsSage
                                : AppColors.jobsObsidian.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (brainwave.type != BrainwaveType.none) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${brainwave.beatFrequency.toInt()}Hz',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? AppColors.jobsSage.withValues(alpha: 0.7)
                                  : AppColors.jobsObsidian
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_showVolumeSlider) ...[
          const SizedBox(height: AppSpacing.spacing16),
          Row(
            children: [
              Icon(
                Icons.volume_down_rounded,
                color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                size: 20,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.jobsSage,
                    inactiveTrackColor:
                        AppColors.jobsSage.withValues(alpha: 0.2),
                    thumbColor: AppColors.jobsSage,
                    overlayColor: AppColors.jobsSage.withValues(alpha: 0.1),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: _updateVolume,
                    min: 0.0,
                    max: 0.5,
                  ),
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
          Text(
            'Keep volume low to protect hearing',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: AppColors.jobsObsidian.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _WaveAnimation extends StatefulWidget {
  final double frequency;
  final bool isPlaying;

  const _WaveAnimation({
    required this.frequency,
    required this.isPlaying,
  });

  @override
  State<_WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<_WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final durationMs = (1000 / (widget.frequency / 2)).clamp(200.0, 2000.0);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs.toInt()),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_WaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(32, 24),
          painter: _WavePainter(
            phase: _controller.value * 2 * math.pi,
            color: AppColors.jobsSage,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final Color color;

  _WavePainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    final amplitude = size.height / 3;

    path.moveTo(0, centerY);

    for (var x = 0.0; x < size.width; x += 1) {
      final y = centerY +
          amplitude * math.sin((x / size.width) * 4 * math.pi + phase);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
