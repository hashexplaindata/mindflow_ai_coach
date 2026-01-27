import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../domain/models/meditation_session.dart';
import '../../domain/models/meditation_category.dart';
import '../../domain/models/guided_content.dart';
import '../../data/ambient_sound_service.dart';
import '../../data/binaural_audio_service.dart';
import '../widgets/breathing_indicator.dart';
import '../widgets/ambient_sound_picker.dart';

class PlayerScreen extends StatefulWidget {
  final MeditationSession meditation;

  const PlayerScreen({super.key, required this.meditation});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  late int _remainingSeconds;
  late int _totalSeconds;
  int _elapsedSeconds = 0;
  Timer? _timer;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _promptFadeController;
  late Animation<double> _promptFadeAnimation;
  bool _isLoggingSession = false;
  
  GuidedContent? _guidedContent;
  GuidedPrompt? _currentPrompt;
  String _displayedPromptText = '';
  
  final AmbientSoundService _ambientSoundService = AmbientSoundService();
  final BinauralAudioService _binauralAudioService = BinauralAudioService();

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.meditation.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    
    _guidedContent = GuidedMeditationScripts.getScript(widget.meditation.id);
    
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _promptFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _promptFadeAnimation = CurvedAnimation(
      parent: _promptFadeController,
      curve: Curves.easeInOut,
    );
    
    if (_guidedContent != null && _guidedContent!.prompts.isNotEmpty) {
      _currentPrompt = _guidedContent!.prompts.first;
      _displayedPromptText = _currentPrompt!.text;
      _promptFadeController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _promptFadeController.dispose();
    _ambientSoundService.stop();
    _binauralAudioService.stop();
    super.dispose();
  }

  void _updateCurrentPrompt() {
    if (_guidedContent == null) return;
    
    final newPrompt = _guidedContent!.getPromptAt(_elapsedSeconds);
    
    if (newPrompt != null && newPrompt != _currentPrompt) {
      _promptFadeController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentPrompt = newPrompt;
            _displayedPromptText = newPrompt.text;
          });
          _promptFadeController.forward();
        }
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _ambientSoundService.resume();
      _binauralAudioService.resume();
      _progressController.forward(from: 1 - (_remainingSeconds / _totalSeconds));
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
            _elapsedSeconds = _totalSeconds - _remainingSeconds;
          });
          _updateCurrentPrompt();
        } else {
          _timer?.cancel();
          setState(() {
            _isPlaying = false;
          });
          _completeSession();
        }
      });
    } else {
      _timer?.cancel();
      _progressController.stop();
      _ambientSoundService.pause();
      _binauralAudioService.pause();
    }
  }

  Future<void> _completeSession() async {
    if (_isLoggingSession) return;
    
    await _ambientSoundService.stop();
    await _binauralAudioService.stop();
    
    setState(() {
      _isLoggingSession = true;
    });

    final completedSeconds = _totalSeconds - _remainingSeconds;
    
    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.logMeditationSession(
        widget.meditation.id,
        completedSeconds,
      );
    } catch (e) {
      debugPrint('Error logging session: $e');
    }

    setState(() {
      _isLoggingSession = false;
    });

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _finishEarly() {
    _timer?.cancel();
    _progressController.stop();
    setState(() {
      _isPlaying = false;
    });
    _completeSession();
  }

  void _showCompletionDialog() {
    final completedMinutes = (_totalSeconds - _remainingSeconds) ~/ 60;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.jobsCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.jobsSage,
                            AppColors.jobsSage.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Session Complete!',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.jobsObsidian,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ve completed ${widget.meditation.title}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  color: AppColors.jobsObsidian.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                completedMinutes > 0 
                    ? '+$completedMinutes minutes added to your journey'
                    : 'Every moment of mindfulness counts!',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.jobsSage,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.jobsSage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / _totalSeconds);
    final hasStarted = _remainingSeconds < _totalSeconds;
    final hasGuidedContent = _guidedContent != null;

    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.jobsObsidian,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.jobsSage.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.meditation.category.displayName,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.jobsSage,
                      ),
                    ),
                  ),
                  if (hasStarted)
                    GestureDetector(
                      onTap: _finishEarly,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.jobsSage,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
              
              const SizedBox(height: AppSpacing.spacing24),
              
              if (hasGuidedContent) ...[
                BreathingIndicator(
                  currentPromptType: _currentPrompt?.type,
                  isPlaying: _isPlaying,
                ),
                const SizedBox(height: AppSpacing.spacing32),
                
                SizedBox(
                  height: 100,
                  child: FadeTransition(
                    opacity: _promptFadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _displayedPromptText,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.jobsObsidian.withOpacity(0.85),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
              ],
              
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = _isPlaying ? 1.0 + (_pulseController.value * 0.015) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: hasGuidedContent ? 200 : 280,
                          height: hasGuidedContent ? 200 : 280,
                          child: CustomPaint(
                            painter: _ProgressRingPainter(
                              progress: progress,
                              strokeWidth: hasGuidedContent ? 12 : 16,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: hasGuidedContent ? 40 : 56,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.jobsObsidian,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'remaining',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      color: AppColors.jobsObsidian.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              Text(
                widget.meditation.title,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.jobsObsidian,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacing8),
              if (!hasGuidedContent)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.meditation.description,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      color: AppColors.jobsObsidian.withOpacity(0.6),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              const SizedBox(height: AppSpacing.spacing16),
              
              AmbientSoundPicker(
                onSoundChanged: (soundType) {
                  if (_isPlaying && soundType != AmbientSoundType.none) {
                    _ambientSoundService.resume();
                  }
                },
                onBrainwaveChanged: (brainwaveType) {
                  if (_isPlaying && brainwaveType != BrainwaveType.none) {
                    _binauralAudioService.resume();
                  }
                },
              ),
              
              const SizedBox(height: AppSpacing.spacing24),
              
              _isLoggingSession
                  ? Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.jobsObsidian.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(AppColors.jobsSage),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _togglePlayPause,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.jobsObsidian,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.jobsObsidian.withOpacity(_isPlaying ? 0.4 : 0.3),
                              blurRadius: _isPlaying ? 30 : 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: AppColors.jobsCream,
                          size: 40,
                        ),
                      ),
                    ),
              
              const SizedBox(height: AppSpacing.spacing24),
              
              if (!_isPlaying && !hasStarted && hasGuidedContent)
                Text(
                  'Tap play to begin your guided meditation',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: AppColors.jobsObsidian.withOpacity(0.5),
                  ),
                ),
              
              const SizedBox(height: AppSpacing.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = AppColors.jobsSage.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = AppColors.jobsSage
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
