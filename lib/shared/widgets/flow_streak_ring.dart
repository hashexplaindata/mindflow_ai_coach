import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class FlowStreakRing extends StatefulWidget {
  const FlowStreakRing({
    super.key,
    required this.streakDays,
    this.maxDays = 30,
    this.size = 180,
    this.strokeWidth = 12,
  });

  final int streakDays;
  final int maxDays;
  final double size;
  final double strokeWidth;

  @override
  State<FlowStreakRing> createState() => _FlowStreakRingState();
}

class _FlowStreakRingState extends State<FlowStreakRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final progress = (widget.streakDays / widget.maxDays).clamp(0.0, 1.0);
    _animation = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(FlowStreakRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakDays != widget.streakDays) {
      final progress = (widget.streakDays / widget.maxDays).clamp(0.0, 1.0);
      _animation = Tween<double>(begin: 0.0, end: progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
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
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _StreakRingPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              ringColor: AppColors.jobsSage,
              trackColor: AppColors.jobsSage.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.streakDays}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.jobsObsidian,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.streakDays == 1 ? 'day' : 'days',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: widget.size * 0.09,
                      fontWeight: FontWeight.w500,
                      color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StreakRingPainter extends CustomPainter {
  _StreakRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.ringColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final ringPaint = Paint()
      ..color = ringColor
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
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(_StreakRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
