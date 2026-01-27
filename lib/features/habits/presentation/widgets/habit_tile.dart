import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/habit.dart';

class HabitTile extends StatefulWidget {
  final Habit habit;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  final bool showStreak;

  const HabitTile({
    super.key,
    required this.habit,
    this.onToggle,
    this.onTap,
    this.showStreak = true,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap ?? _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _CheckBox(
                isChecked: widget.habit.isCompletedToday,
                onTap: _handleTap,
              ),
              const SizedBox(width: AppSpacing.spacing12),
              Text(
                widget.habit.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.spacing12),
              Expanded(
                child: Text(
                  widget.habit.name,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.habit.isCompletedToday
                        ? AppColors.jobsObsidian.withOpacity(0.5)
                        : AppColors.jobsObsidian,
                    decoration: widget.habit.isCompletedToday
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.jobsObsidian.withOpacity(0.5),
                  ),
                ),
              ),
              if (widget.showStreak && widget.habit.streakCount > 0)
                StreakBadge(streakCount: widget.habit.streakCount),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback? onTap;

  const _CheckBox({
    required this.isChecked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.jobsSage : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isChecked ? AppColors.jobsSage : AppColors.jobsObsidian.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: isChecked
            ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              )
            : null,
      ),
    );
  }
}

class StreakBadge extends StatelessWidget {
  final int streakCount;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.streakCount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (streakCount <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: compact ? 12 : 14,
            color: AppColors.primaryOrange,
          ),
          const SizedBox(width: 2),
          Text(
            '$streakCount',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class HabitTileCompact extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;

  const HabitTileCompact({
    super.key,
    required this.habit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobsObsidian.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.jobsSage.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  habit.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jobsObsidian,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.category.displayName,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.jobsObsidian.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (habit.streakCount > 0)
              StreakBadge(streakCount: habit.streakCount, compact: true),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.jobsObsidian.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
