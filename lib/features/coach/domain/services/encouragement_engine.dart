import 'dart:math';
import '../models/coaching_intervention.dart';

/// Encouragement Engine
/// 
/// Provides thoughtful, varied acknowledgments to support user progress.
/// Uses unpredictable timing to keep interactions feeling fresh and genuine.
class EncouragementEngine {
  EncouragementEngine._();

  static final Random _random = Random();

  // Milestone thresholds: Key moments in the user's journey
  // Each represents a meaningful point worth acknowledging
  static const List<int> _milestoneThresholds = [1, 3, 7, 14, 21, 30, 60, 90, 180, 365];

  // Show acknowledgment 30% of the time for variety
  static bool shouldShowAcknowledgment() {
    return _random.nextDouble() < 0.30;
  }

  // Gentle streak reminders 15% of the time
  static bool shouldShowStreakReminder() {
    return _random.nextDouble() < 0.15;
  }

  // Vary the warmth of acknowledgments
  static double getWarmthMultiplier() {
    final multipliers = [1.5, 2.0, 2.5, 3.0];
    return multipliers[_random.nextInt(multipliers.length)];
  }

  // Occasional special acknowledgment (10% chance)
  static bool shouldShowSpecialMoment() {
    return _random.nextDouble() < 0.10;
  }

  // Determine the best moment to offer encouragement
  static bool isOptimalEncouragementMoment(int elapsedSeconds, int totalSeconds) {
    final progress = elapsedSeconds / totalSeconds;
    // Encourage at midpoint (50%) or near completion (90%+)
    return (progress >= 0.48 && progress <= 0.52) || progress >= 0.90;
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
        return 'Three Week Journey';
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
    required PracticeStage state,
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

    if (!shouldShowAcknowledgment()) {
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
    final ratio = getWarmthMultiplier();

    return CoachingIntervention(
      id: id,
      type: InterventionType.celebration,
      message: message,
      subMessage: ratio > 1.5 ? 'Extra warmth for your dedication.' : null,
      createdAt: now,
      priority: 5,
      metadata: {
        'warmth': ratio,
        'sessions': sessionsCompleted,
        'streak': currentStreak,
      },
    );
  }

  // Milestone messages: Gentle, experiential, identity-focused
  // No medical claims, no unverifiable stats
  // Focus on felt experience and meaning
  static String _getMilestoneMessage(int streak) {
    switch (streak) {
      case 1:
        return 'You showed up. That\'s the foundation of everything.';
      case 3:
        return 'Three days. Something is shifting. You can feel it.';
      case 7:
        return 'A full week. You\'re building something meaningful.';
      case 14:
        return 'Two weeks. This is becoming part of who you are.';
      case 21:
        return 'Three weeks. The practice is finding its rhythm in your life.';
      case 30:
        return 'One month. You\'ve proven something to yourself.';
      case 60:
        return 'Sixty days. This level of consistency is rare and valuable.';
      case 90:
        return 'A quarter year. You\'re living this now, not just practicing it.';
      case 180:
        return 'Half a year of presence. This is who you\'ve become.';
      case 365:
        return 'One year. You didn\'t just build a habit. You changed.';
      default:
        return 'Every session matters. Keep going.';
    }
  }

  // Celebration messages: Gentle, experiential
  // No medical claims, focus on felt experience
  static List<String> _getCelebrationsByState({
    required PracticeStage state,
    required int streak,
    required int sessions,
    required int minutes,
  }) {
    switch (state) {
      case PracticeStage.newUser:
        return [
          '$minutes minutes invested in yourself. It adds up.',
          'You started. That\'s the hardest part.',
          'Your future self will thank you for this.',
          'First sessions matter most. This one counts.',
          'You chose to show up. That says something.',
        ];
      case PracticeStage.developing:
        return [
          'Day $streak. You can feel the difference, can\'t you?',
          '$sessions sessions complete. Something is building.',
          'Consistency over intensity. You understand that now.',
          'The practice is becoming familiar. That\'s the point.',
          'Each session makes the next one easier.',
        ];
      case PracticeStage.established:
        return [
          'Another day of practice. Another layer of calm.',
          '$streak days. This is who you are now.',
          'You\'ve made this part of your life. That\'s rare.',
          'You\'re not just practicing. You\'re living it.',
          'The change is visible. Others notice.',
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
    final bonusMultiplier = bonusApplied ? getWarmthMultiplier() : 1.0;

    return (basePoints * multiplier * bonusMultiplier).round();
  }
}
