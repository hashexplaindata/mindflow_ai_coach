import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/guided_content.dart';

class BreathingIndicator extends StatefulWidget {
  final PromptType? currentPromptType;
  final bool isPlaying;

  const BreathingIndicator({
    super.key,
    this.currentPromptType,
    required this.isPlaying,
  });

  @override
  State<BreathingIndicator> createState() => _BreathingIndicatorState();
}

class _BreathingIndicatorState extends State<BreathingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _updateBreathingAnimation();
  }

  @override
  void didUpdateWidget(BreathingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPromptType != widget.currentPromptType ||
        oldWidget.isPlaying != widget.isPlaying) {
      _updateBreathingAnimation();
    }
  }

  void _updateBreathingAnimation() {
    if (!widget.isPlaying) {
      _breatheController.stop();
      return;
    }

    switch (widget.currentPromptType) {
      case PromptType.breatheIn:
        _breatheController.duration = const Duration(seconds: 4);
        _breatheController.forward(from: 0);
        break;
      case PromptType.hold:
        _breatheController.stop();
        break;
      case PromptType.breatheOut:
        _breatheController.duration = const Duration(seconds: 6);
        _breatheController.reverse(from: 1);
        break;
      default:
        if (!_breatheController.isAnimating) {
          _breatheController.duration = const Duration(seconds: 8);
          _breatheController.repeat(reverse: true);
        }
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getColorForPromptType() {
    switch (widget.currentPromptType) {
      case PromptType.breatheIn:
        return AppColors.jobsSage;
      case PromptType.hold:
        return AppColors.accentBlue;
      case PromptType.breatheOut:
        return AppColors.primaryOrange.withValues(alpha: 0.8);
      case PromptType.affirmation:
        return AppColors.accentYellow;
      default:
        return AppColors.jobsSage;
    }
  }

  String _getBreathingLabel() {
    switch (widget.currentPromptType) {
      case PromptType.breatheIn:
        return 'Breathe In';
      case PromptType.hold:
        return 'Hold';
      case PromptType.breatheOut:
        return 'Breathe Out';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBreathingPrompt =
        widget.currentPromptType == PromptType.breatheIn ||
            widget.currentPromptType == PromptType.hold ||
            widget.currentPromptType == PromptType.breatheOut;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        final scale = widget.isPlaying ? _scaleAnimation.value : 0.9;
        final glowOpacity = _glowAnimation.value;
        final color = _getColorForPromptType();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.4),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: glowOpacity * 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.3),
                      border: Border.all(
                        color: color.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isBreathingPrompt && widget.isPlaying) ...[
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _getBreathingLabel(),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class BreathingExerciseWidget extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onComplete;

  const BreathingExerciseWidget({
    super.key,
    required this.isActive,
    this.onComplete,
  });

  @override
  State<BreathingExerciseWidget> createState() =>
      _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  BreathPhase _currentPhase = BreathPhase.inhale;
  int _cycleCount = 0;
  static const int _totalCycles = 4;

  static const int _inhaleDuration = 4;
  static const int _holdDuration = 7;
  static const int _exhaleDuration = 8;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.isActive) {
      _startBreathingCycle();
    }
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _inhaleDuration),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BreathingExerciseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _cycleCount = 0;
      _startBreathingCycle();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  void _startBreathingCycle() {
    if (!mounted || !widget.isActive) return;

    setState(() {
      _currentPhase = BreathPhase.inhale;
    });

    _controller.duration = const Duration(seconds: _inhaleDuration);
    _controller.forward(from: 0).then((_) {
      if (!mounted || !widget.isActive) return;

      setState(() {
        _currentPhase = BreathPhase.hold;
      });

      Future.delayed(const Duration(seconds: _holdDuration), () {
        if (!mounted || !widget.isActive) return;

        setState(() {
          _currentPhase = BreathPhase.exhale;
        });

        _controller.duration = const Duration(seconds: _exhaleDuration);
        _controller.reverse(from: 1).then((_) {
          if (!mounted || !widget.isActive) return;

          _cycleCount++;
          if (_cycleCount < _totalCycles) {
            _startBreathingCycle();
          } else {
            widget.onComplete?.call();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPhaseText() {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return 'Breathe In';
      case BreathPhase.hold:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Breathe Out';
    }
  }

  String _getPhaseDuration() {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return '$_inhaleDuration seconds';
      case BreathPhase.hold:
        return '$_holdDuration seconds';
      case BreathPhase.exhale:
        return '$_exhaleDuration seconds';
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return AppColors.jobsSage;
      case BreathPhase.hold:
        return AppColors.accentBlue;
      case BreathPhase.exhale:
        return AppColors.primaryOrange.withValues(alpha: 0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPhaseColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '4-7-8 Breathing',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.jobsObsidian.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cycle ${_cycleCount + 1} of $_totalCycles',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.jobsObsidian.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: _opacityAnimation.value * 0.6),
                      color.withValues(alpha: _opacityAnimation.value * 0.2),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(
                          alpha: _opacityAnimation.value * 0.4),
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.4),
                      border: Border.all(
                        color: color.withValues(alpha: 0.8),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _getPhaseText(),
                key: ValueKey(_currentPhase),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPhaseDuration(),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                color: AppColors.jobsObsidian.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum BreathPhase { inhale, hold, exhale }
