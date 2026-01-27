import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/coaching_intervention.dart';
import '../providers/background_coach_provider.dart';

class CoachInterventionOverlay extends StatefulWidget {
  const CoachInterventionOverlay({
    super.key,
    required this.intervention,
    required this.onAccept,
    required this.onPostpone,
    required this.onDismiss,
  });

  final CoachingIntervention intervention;
  final VoidCallback onAccept;
  final VoidCallback onPostpone;
  final VoidCallback onDismiss;

  @override
  State<CoachInterventionOverlay> createState() =>
      _CoachInterventionOverlayState();
}

class _CoachInterventionOverlayState extends State<CoachInterventionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  static const Duration _animationDuration = Duration(milliseconds: 400);
  static const Duration _autoDismissDelay = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    _autoDismissTimer = Timer(_autoDismissDelay, () {
      _dismiss();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _autoDismissTimer?.cancel();
    await _controller.reverse();
    widget.onDismiss();
  }

  Future<void> _accept() async {
    _autoDismissTimer?.cancel();
    await _controller.reverse();
    widget.onAccept();
  }

  Future<void> _postpone() async {
    _autoDismissTimer?.cancel();
    await _controller.reverse();
    widget.onPostpone();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {},
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy > 100) {
                      _dismiss();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.spacing16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardBackgroundDark
                          : AppColors.jobsSage.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? Colors.white
                                      : Colors.white)
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.spacing24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.intervention.icon,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.spacing16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getTypeLabel(
                                                widget.intervention.type),
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: Colors.white
                                                  .withOpacity(0.7),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            widget.intervention.message,
                                            style: AppTextStyles.headingSmall
                                                .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.intervention.subMessage != null) ...[
                                  const SizedBox(height: AppSpacing.spacing16),
                                  Text(
                                    widget.intervention.subMessage!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.spacing24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: _postpone,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: AppSpacing.spacing16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusButton,
                                            ),
                                            side: BorderSide(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Maybe Later',
                                          style: AppTextStyles.buttonMedium
                                              .copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.spacing12),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: _accept,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppColors.jobsSage,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: AppSpacing.spacing16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusButton,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          widget.intervention.actionLabel ??
                                              'Let\'s Go',
                                          style: AppTextStyles.buttonMedium
                                              .copyWith(
                                            color: isDark
                                                ? AppColors.jobsSageDark
                                                : AppColors.jobsSage,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(InterventionType type) {
    switch (type) {
      case InterventionType.nudge:
        return 'GENTLE REMINDER';
      case InterventionType.celebration:
        return 'CELEBRATION';
      case InterventionType.milestone:
        return 'MILESTONE REACHED';
      case InterventionType.recommendation:
        return 'FOR YOU';
      case InterventionType.streakWarning:
        return 'STREAK UPDATE';
      case InterventionType.streakRecovery:
        return 'WELCOME BACK';
    }
  }
}

class CoachInterventionManager extends StatefulWidget {
  const CoachInterventionManager({
    super.key,
    required this.child,
    this.onNavigateToMeditation,
    this.onNavigateToHabits,
    this.onNavigateToProgress,
  });

  final Widget child;
  final VoidCallback? onNavigateToMeditation;
  final VoidCallback? onNavigateToHabits;
  final VoidCallback? onNavigateToProgress;

  @override
  State<CoachInterventionManager> createState() =>
      _CoachInterventionManagerState();
}

class _CoachInterventionManagerState extends State<CoachInterventionManager> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListener();
    });
  }

  void _setupListener() {
    final provider = context.read<BackgroundCoachProvider>();
    provider.setInterventionCallback(_showOverlay);
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final provider = context.read<BackgroundCoachProvider>();
    final intervention = provider.currentIntervention;
    if (intervention == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => CoachInterventionOverlay(
        intervention: intervention,
        onAccept: () => _handleAccept(intervention),
        onPostpone: _handlePostpone,
        onDismiss: _handleDismiss,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _handleAccept(CoachingIntervention intervention) {
    _removeOverlay();

    final provider = context.read<BackgroundCoachProvider>();
    provider.acceptIntervention(intervention.actionLabel ?? 'accepted');

    final category = intervention.metadata?['category'] as String?;
    final trigger = intervention.metadata?['trigger'] as String?;

    if (trigger == 'habitReminder') {
      widget.onNavigateToHabits?.call();
    } else if (trigger == 'goalProgress') {
      widget.onNavigateToProgress?.call();
    } else if (category == 'focus' || category == 'sleep' || category == 'stress') {
      widget.onNavigateToMeditation?.call();
    } else {
      widget.onNavigateToMeditation?.call();
    }
  }

  void _handlePostpone() {
    _removeOverlay();
    final provider = context.read<BackgroundCoachProvider>();
    provider.postponeIntervention();
  }

  void _handleDismiss() {
    _removeOverlay();
    final provider = context.read<BackgroundCoachProvider>();
    provider.dismissIntervention();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
