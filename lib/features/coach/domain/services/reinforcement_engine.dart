import 'dart:math';
import '../models/coaching_intervention.dart';

class ReinforcementEngine {
  ReinforcementEngine._();

  static final Random _random = Random();

  static const List<int> _milestoneThresholds = [1, 3, 7, 14, 21, 30, 60, 90, 180, 365];

  static bool shouldShowVariableReward() {
    return _random.nextDouble() < 0.3;
  }

  static double getVariableRatio() {
    final ratios = [1.5, 2.0, 2.5, 3.0];
    return ratios[_random.nextInt(ratios.length)];
  }

  static int? getNextMilestone(int currentStreak) {
    for (final threshold in _milestoneThresholds) {
      if (currentStreak < threshold) {
        return threshold;
      }
    }
    return null;
  }

  static bool isNewMilestone(int currentStreak) {
    return _milestoneThresholds.contains(currentStreak);
  }

  static String getMilestoneTitle(int streak) {
    switch (streak) {
      case 1:
        return 'First Step';
      case 3:
        return 'Momentum Builder';
      case 7:
        return 'Week Warrior';
      case 14:
        return 'Fortnight Focus';
      case 21:
        return 'Habit Formed';
      case 30:
        return 'Monthly Master';
      case 60:
        return 'Dedicated Mind';
      case 90:
        return 'Quarterly Quest';
      case 180:
        return 'Half Year Hero';
      case 365:
        return 'Mindfulness Master';
      default:
        return 'Milestone Achieved';
    }
  }

  static double getStreakMultiplier(int streak) {
    if (streak <= 0) return 1.0;
    if (streak < 3) return 1.0;
    if (streak < 7) return 1.25;
    if (streak < 14) return 1.5;
    if (streak < 30) return 1.75;
    if (streak < 60) return 2.0;
    return 2.5;
  }

  static CoachingIntervention? getCelebration({
    required int sessionsCompleted,
    required int currentStreak,
    required int durationMinutes,
    required ConditioningState state,
  }) {
    final now = DateTime.now();
    final id = 'celebration_${now.millisecondsSinceEpoch}';

    if (isNewMilestone(currentStreak)) {
      return CoachingIntervention(
        id: id,
        type: InterventionType.milestone,
        message: getMilestoneTitle(currentStreak),
        subMessage: _getMilestoneMessage(currentStreak),
        createdAt: now,
        priority: 10,
        metadata: {
          'milestone': currentStreak,
          'type': 'streak',
        },
      );
    }

    if (!shouldShowVariableReward()) {
      return null;
    }

    final celebrations = _getCelebrationsByState(
      state: state,
      streak: currentStreak,
      sessions: sessionsCompleted,
      minutes: durationMinutes,
    );

    if (celebrations.isEmpty) return null;

    final message = celebrations[_random.nextInt(celebrations.length)];
    final ratio = getVariableRatio();

    return CoachingIntervention(
      id: id,
      type: InterventionType.celebration,
      message: message,
      subMessage: ratio > 1.5 ? '${ratio.toStringAsFixed(0)}x mindfulness bonus earned' : null,
      createdAt: now,
      priority: 5,
      metadata: {
        'multiplier': ratio,
        'sessions': sessionsCompleted,
        'streak': currentStreak,
      },
    );
  }

  static String _getMilestoneMessage(int streak) {
    switch (streak) {
      case 1:
        return 'You showed up. That\'s everything.';
      case 3:
        return 'Three days. Your mind is starting to notice.';
      case 7:
        return 'A full week. New neural pathways are forming.';
      case 14:
        return 'Two weeks of presence. This is becoming part of you.';
      case 21:
        return 'Science says habits form in 21 days. You\'re there.';
      case 30:
        return 'A month of mindfulness. You\'ve transformed your baseline.';
      case 60:
        return 'Sixty days of consistency. This is who you are now.';
      case 90:
        return 'A quarter year of practice. Exceptional.';
      case 180:
        return 'Half a year. You\'re in the top 1% of practitioners.';
      case 365:
        return 'A full year. You\'ve mastered the art of showing up.';
      default:
        return 'Keep going. Every session matters.';
    }
  }

  static List<String> _getCelebrationsByState({
    required ConditioningState state,
    required int streak,
    required int sessions,
    required int minutes,
  }) {
    switch (state) {
      case ConditioningState.newUser:
        return [
          'You just invested $minutes minutes in yourself. That compounds.',
          'Starting is the hardest part. You did it.',
          'Your future self thanks you for this.',
          'One session closer to a calmer mind.',
        ];
      case ConditioningState.habitForming:
        return [
          'That\'s $streak days in a row. Your mind is rewiring.',
          'Flow state unlocked. Your brain thanks you.',
          '$sessions sessions complete. Building something real.',
          'Consistency creates transformation. You\'re doing it.',
        ];
      case ConditioningState.habitEstablished:
        return [
          'Another day, another layer of calm added.',
          'Your $streak-day streak is inspiring.',
          'Master level consistency. This is rare.',
          'You\'re not just practicing. You\'re living it.',
        ];
    }
  }

  static CoachingIntervention? getComebackReward({
    required int daysSinceLastSession,
    required int previousStreak,
    required int totalSessions,
  }) {
    if (daysSinceLastSession < 2) return null;

    final now = DateTime.now();
    final id = 'comeback_${now.millisecondsSinceEpoch}';

    if (previousStreak >= 7) {
      return CoachingIntervention(
        id: id,
        type: InterventionType.streakRecovery,
        message: 'Welcome back.',
        subMessage: 'You had a $previousStreak-day streak. Let\'s rebuild it.',
        actionLabel: 'Start Fresh',
        createdAt: now,
        priority: 8,
        requiresAction: true,
        metadata: {
          'previousStreak': previousStreak,
          'daysMissed': daysSinceLastSession,
        },
      );
    }

    if (daysSinceLastSession >= 7) {
      return CoachingIntervention(
        id: id,
        type: InterventionType.streakRecovery,
        message: 'Starting again is the hardest part.',
        subMessage: 'You just did it by opening this app.',
        actionLabel: 'Begin Again',
        createdAt: now,
        priority: 7,
        requiresAction: true,
      );
    }

    return null;
  }

  static int calculateProgressPoints({
    required int durationMinutes,
    required int currentStreak,
    required bool bonusApplied,
  }) {
    final basePoints = durationMinutes * 10;
    final multiplier = getStreakMultiplier(currentStreak);
    final bonusMultiplier = bonusApplied ? getVariableRatio() : 1.0;

    return (basePoints * multiplier * bonusMultiplier).round();
  }
}
