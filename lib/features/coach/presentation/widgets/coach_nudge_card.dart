import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/coaching_intervention.dart';

class CoachNudgeCard extends StatefulWidget {
  final CoachingIntervention intervention;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const CoachNudgeCard({
    super.key,
    required this.intervention,
    this.onAction,
    this.onDismiss,
  });

  @override
  State<CoachNudgeCard> createState() => _CoachNudgeCardState();
}

class _CoachNudgeCardState extends State<CoachNudgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.intervention.type) {
      case InterventionType.streakWarning:
        return const Color(0xFFFFF3E0);
      case InterventionType.celebration:
      case InterventionType.milestone:
        return const Color(0xFFF3E5F5);
      case InterventionType.streakRecovery:
        return const Color(0xFFE8F5E9);
      default:
        return AppColors.jobsSage.withValues(alpha: 0.15);
    }
  }

  Color get _accentColor {
    switch (widget.intervention.type) {
      case InterventionType.streakWarning:
        return AppColors.primaryOrange;
      case InterventionType.celebration:
      case InterventionType.milestone:
        return const Color(0xFF9C27B0);
      case InterventionType.streakRecovery:
        return AppColors.jobsSage;
      default:
        return AppColors.jobsSage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: widget.intervention.isUrgent ? _pulseAnimation.value : 1.0,
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: widget.intervention.isUrgent
            ? Border.all(color: _accentColor.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.intervention.message,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.jobsObsidian,
                          height: 1.3,
                        ),
                      ),
                      if (widget.intervention.subMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.intervention.subMessage!,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color:
                                AppColors.jobsObsidian.withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.onDismiss != null)
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.jobsObsidian.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.intervention.actionLabel != null &&
                widget.onAction != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  _buildActionButton(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          widget.intervention.icon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onAction,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.intervention.actionLabel!,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class CelebrationOverlay extends StatefulWidget {
  final CoachingIntervention celebration;
  final VoidCallback onDismiss;

  const CelebrationOverlay({
    super.key,
    required this.celebration,
    required this.onDismiss,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildCelebrationCard(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.celebration.icon,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            widget.celebration.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.jobsObsidian,
            ),
          ),
          if (widget.celebration.subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.celebration.subMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                color: AppColors.jobsObsidian.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
