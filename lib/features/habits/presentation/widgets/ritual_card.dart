import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/daily_ritual.dart';

class RitualCard extends StatelessWidget {
  final DailyRitual ritual;
  final VoidCallback? onTap;

  const RitualCard({
    super.key,
    required this.ritual,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsObsidian.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _RitualProgressRing(
              progress: ritual.progress,
              emoji: ritual.emoji,
              size: 64,
            ),
            const SizedBox(width: AppSpacing.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ritual.title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jobsObsidian,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ritual.completedHabits}/${ritual.totalHabits} completed',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (ritual.isComplete)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.jobsSage.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.jobsSage,
                  size: 20,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.jobsObsidian.withValues(alpha: 0.3),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class _RitualProgressRing extends StatelessWidget {
  final double progress;
  final String emoji;
  final double size;

  const _RitualProgressRing({
    required this.progress,
    required this.emoji,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: progress,
              strokeWidth: 4,
              backgroundColor: AppColors.jobsSage.withValues(alpha: 0.15),
              progressColor: AppColors.jobsSage,
            ),
          ),
          Text(
            emoji,
            style: TextStyle(fontSize: size * 0.4),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class RitualCardExpanded extends StatelessWidget {
  final DailyRitual ritual;
  final Widget child;

  const RitualCardExpanded({
    super.key,
    required this.ritual,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.jobsObsidian.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _RitualProgressRing(
                  progress: ritual.progress,
                  emoji: ritual.emoji,
                  size: 56,
                ),
                const SizedBox(width: AppSpacing.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ritual.title,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.jobsObsidian,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ritual.subtitle,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (ritual.isComplete)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.jobsSage.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.jobsSage,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Complete',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.jobsSage,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          child,
        ],
      ),
    );
  }
}
