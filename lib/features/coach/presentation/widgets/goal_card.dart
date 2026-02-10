import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/wellness_goal.dart';

class GoalCard extends StatelessWidget {
  final WellnessGoal goal;
  final VoidCallback? onTap;
  final bool showCelebration;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.showCelebration = false,
  });

  IconData _getIcon() {
    switch (goal.iconType) {
      case IconType.fire:
        return Icons.local_fire_department_rounded;
      case IconType.timer:
        return Icons.timer_outlined;
      case IconType.calendar:
        return Icons.calendar_today_rounded;
      case IconType.star:
        return Icons.star_rounded;
    }
  }

  Color _getProgressColor() {
    if (goal.isComplete) return AppColors.successGreen;
    if (goal.progressPercent >= 0.75) return AppColors.jobsSage;
    if (goal.progressPercent >= 0.5) return AppColors.primaryOrange;
    return AppColors.accentBlue;
  }

  String _getEstimatedCompletion() {
    if (goal.isComplete) return 'Completed!';

    final remaining = goal.targetValue - goal.currentValue;
    switch (goal.type) {
      case GoalType.streakDays:
        return '$remaining days to go';
      case GoalType.totalMinutes:
        return '$remaining min remaining';
      case GoalType.sessionsPerWeek:
        return '$remaining more sessions';
      case GoalType.categoryMastery:
        return '$remaining sessions left';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: goal.isComplete
                            ? AppColors.successGreen.withValues(alpha: 0.15)
                            : _getProgressColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        goal.isComplete
                            ? Icons.check_circle_rounded
                            : _getIcon(),
                        color: goal.isComplete
                            ? AppColors.successGreen
                            : _getProgressColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.jobsObsidian,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal.description,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color:
                                  AppColors.jobsObsidian.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (goal.isComplete && showCelebration) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.celebration_rounded,
                              size: 14,
                              color: AppColors.successGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Done!',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: goal.progressPercent,
                    backgroundColor:
                        AppColors.jobsObsidian.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal.progressText,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _getProgressColor(),
                      ),
                    ),
                    Text(
                      _getEstimatedCompletion(),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.jobsObsidian.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoalTemplateCard extends StatelessWidget {
  final GoalTemplate template;
  final VoidCallback onSelect;

  const GoalTemplateCard({
    super.key,
    required this.template,
    required this.onSelect,
  });

  IconData _getIcon() {
    switch (template.type) {
      case GoalType.streakDays:
        return Icons.local_fire_department_rounded;
      case GoalType.totalMinutes:
        return Icons.timer_outlined;
      case GoalType.sessionsPerWeek:
        return Icons.calendar_today_rounded;
      case GoalType.categoryMastery:
        return Icons.star_rounded;
    }
  }

  String _getTitle() {
    switch (template.type) {
      case GoalType.streakDays:
        return '${template.targetValue}-Day Streak';
      case GoalType.totalMinutes:
        return '${template.targetValue} Minutes';
      case GoalType.sessionsPerWeek:
        return '${template.targetValue} Sessions/Week';
      case GoalType.categoryMastery:
        return 'Master ${template.category ?? "Category"}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.jobsObsidian.withValues(alpha: 0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.jobsSage.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: AppColors.jobsSage,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(),
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.jobsObsidian,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        template.motivationalMessage,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.jobsSage,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompactGoalCard extends StatelessWidget {
  final WellnessGoal? goal;
  final VoidCallback? onTap;
  final VoidCallback? onViewAll;

  const CompactGoalCard({
    super.key,
    this.goal,
    this.onTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.jobsSage.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: AppColors.jobsSage,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set Your First Goal',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.jobsObsidian,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Start small, build big',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color:
                                AppColors.jobsObsidian.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.jobsSage,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      goal!.isComplete
                          ? Icons.check_circle_rounded
                          : Icons.flag_rounded,
                      color: goal!.isComplete
                          ? AppColors.successGreen
                          : AppColors.jobsSage,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal!.isComplete ? 'Goal Achieved!' : 'Current Goal',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: goal!.isComplete
                              ? AppColors.successGreen
                              : AppColors.jobsObsidian.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.jobsSage,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.jobsSage,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing12),
                Text(
                  goal!.title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.jobsObsidian,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal!.progressPercent,
                    backgroundColor:
                        AppColors.jobsObsidian.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(
                      goal!.isComplete
                          ? AppColors.successGreen
                          : AppColors.jobsSage,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  goal!.progressText,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.jobsObsidian.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
