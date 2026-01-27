import 'dart:math';
import '../models/coaching_intervention.dart';
import 'reinforcement_engine.dart';

class ProactiveCoachService {
  ProactiveCoachService._();

  static final Random _random = Random();

  static CoachingIntervention? getProactiveNudge({
    required int currentStreak,
    required int totalSessions,
    required int totalMinutes,
    DateTime? lastSessionDate,
  }) {
    final now = DateTime.now();
    final hour = now.hour;
    final id = 'nudge_${now.millisecondsSinceEpoch}';

    final state = UserCoachingState.fromProgress(
      totalSessions: totalSessions,
      currentStreak: currentStreak,
      longestStreak: currentStreak,
      lastSessionDate: lastSessionDate,
    );

    if (state.streakAtRisk && currentStreak >= 3) {
      return _getStreakWarning(
        id: id,
        streak: currentStreak,
        now: now,
      );
    }

    if (state.daysSinceLastSession >= 2) {
      return ReinforcementEngine.getComebackReward(
        daysSinceLastSession: state.daysSinceLastSession,
        previousStreak: currentStreak,
        totalSessions: totalSessions,
      );
    }

    return _getTimeBasedNudge(
      id: id,
      hour: hour,
      state: state,
      now: now,
    );
  }

  static CoachingIntervention _getStreakWarning({
    required String id,
    required int streak,
    required DateTime now,
  }) {
    final hoursLeft = 24 - now.hour;
    
    final messages = [
      'Your $streak-day streak ends in $hoursLeft hours. 5 minutes can save it.',
      '$streak days of work on the line. Protect your progress.',
      'Don\'t let today break your $streak-day momentum.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.streakWarning,
      message: messages[_random.nextInt(messages.length)],
      subMessage: 'A quick session is all it takes.',
      actionLabel: 'Save Streak',
      createdAt: now,
      priority: 9,
      requiresAction: true,
      metadata: {
        'streak': streak,
        'hoursRemaining': hoursLeft,
      },
    );
  }

  static CoachingIntervention? _getTimeBasedNudge({
    required String id,
    required int hour,
    required UserCoachingState state,
    required DateTime now,
  }) {
    String message;
    String? subMessage;
    String? actionLabel;
    String? meditationCategory;

    if (hour >= 5 && hour < 10) {
      final morningNudges = _getMorningNudges(state);
      message = morningNudges[_random.nextInt(morningNudges.length)];
      subMessage = 'Morning minds absorb more.';
      actionLabel = 'Morning Calm';
      meditationCategory = 'focus';
    } else if (hour >= 10 && hour < 14) {
      final middayNudges = _getMiddayNudges(state);
      message = middayNudges[_random.nextInt(middayNudges.length)];
      subMessage = 'A midday reset goes a long way.';
      actionLabel = 'Quick Reset';
      meditationCategory = 'stress';
    } else if (hour >= 14 && hour < 18) {
      final afternoonNudges = _getAfternoonNudges(state);
      message = afternoonNudges[_random.nextInt(afternoonNudges.length)];
      subMessage = 'Afternoon clarity awaits.';
      actionLabel = 'Recharge';
      meditationCategory = 'focus';
    } else if (hour >= 18 && hour < 22) {
      final eveningNudges = _getEveningNudges(state);
      message = eveningNudges[_random.nextInt(eveningNudges.length)];
      subMessage = 'Wind down with intention.';
      actionLabel = 'Evening Unwind';
      meditationCategory = 'sleep';
    } else {
      final nightNudges = _getNightNudges(state);
      message = nightNudges[_random.nextInt(nightNudges.length)];
      subMessage = 'Prepare for restful sleep.';
      actionLabel = 'Sleep Story';
      meditationCategory = 'sleep';
    }

    return CoachingIntervention(
      id: id,
      type: InterventionType.nudge,
      message: message,
      subMessage: subMessage,
      actionLabel: actionLabel,
      createdAt: now,
      priority: 3,
      requiresAction: true,
      metadata: {
        'timeOfDay': _getTimeOfDay(hour),
        'category': meditationCategory,
      },
    );
  }

  static String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 10) return 'morning';
    if (hour >= 10 && hour < 14) return 'midday';
    if (hour >= 14 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 22) return 'evening';
    return 'night';
  }

  static List<String> _getMorningNudges(UserCoachingState state) {
    switch (state.conditioningState) {
      case ConditioningState.newUser:
        return [
          'Good morning. Your mind is most receptive now.',
          'A calm morning creates a calm day.',
          'Start before the world gets loud.',
        ];
      case ConditioningState.habitForming:
        return [
          'Good morning. Day ${state.currentStreak + 1} awaits.',
          'Your morning routine is taking shape.',
          'Same time, same calm. Building something real.',
        ];
      case ConditioningState.habitEstablished:
        return [
          'Your morning ritual awaits.',
          'The mind you\'ve built craves this.',
          'Another morning, another layer of peace.',
        ];
    }
  }

  static List<String> _getMiddayNudges(UserCoachingState state) {
    return [
      'Halfway through. Pause and recalibrate.',
      'A 5-minute reset changes the entire afternoon.',
      'Step back from the noise. Just briefly.',
    ];
  }

  static List<String> _getAfternoonNudges(UserCoachingState state) {
    return [
      'Decompress from the day. 5 minutes of calm.',
      'The afternoon slump is optional.',
      'Restore focus before the final push.',
    ];
  }

  static List<String> _getEveningNudges(UserCoachingState state) {
    return [
      'Wind down with tonight\'s session.',
      'Process the day. Let it go.',
      'Evening stillness leads to morning clarity.',
    ];
  }

  static List<String> _getNightNudges(UserCoachingState state) {
    return [
      'Quiet the mind for deeper sleep.',
      'A sleep story awaits you.',
      'Let tonight restore tomorrow\'s energy.',
    ];
  }

  static CoachingIntervention? getCelebration({
    required int sessionsCompleted,
    required int currentStreak,
    required int durationMinutes,
    required int totalMinutes,
  }) {
    final state = _getConditioningState(sessionsCompleted, currentStreak);

    return ReinforcementEngine.getCelebration(
      sessionsCompleted: sessionsCompleted,
      currentStreak: currentStreak,
      durationMinutes: durationMinutes,
      state: state,
    );
  }

  static CoachingIntervention getRecommendation({
    required DateTime now,
    required int currentStreak,
    required int totalSessions,
    String? preferredCategory,
  }) {
    final hour = now.hour;
    final id = 'rec_${now.millisecondsSinceEpoch}';
    
    String category;
    String title;
    String reason;

    if (hour >= 5 && hour < 10) {
      category = 'focus';
      title = 'Morning Focus';
      reason = 'Cortisol peaks in the morning. Ride it.';
    } else if (hour >= 10 && hour < 14) {
      category = 'stress';
      title = 'Stress Relief';
      reason = 'Midday tensions need releasing.';
    } else if (hour >= 14 && hour < 18) {
      category = 'focus';
      title = 'Afternoon Clarity';
      reason = 'Beat the slump with presence.';
    } else if (hour >= 18 && hour < 22) {
      category = 'anxiety';
      title = 'Evening Calm';
      reason = 'Process the day before it ends.';
    } else {
      category = 'sleep';
      title = 'Sleep Preparation';
      reason = 'Quality sleep starts with a quiet mind.';
    }

    return CoachingIntervention(
      id: id,
      type: InterventionType.recommendation,
      message: title,
      subMessage: reason,
      actionLabel: 'Start Now',
      createdAt: now,
      priority: 4,
      requiresAction: true,
      metadata: {
        'category': category,
        'timeOptimized': true,
      },
    );
  }

  static ConditioningState _getConditioningState(int sessions, int streak) {
    if (sessions < 3) return ConditioningState.newUser;
    if (streak < 7) return ConditioningState.habitForming;
    return ConditioningState.habitEstablished;
  }

  static bool shouldShowNudge({
    required DateTime? lastNudgeDismissed,
    required DateTime? lastSessionCompleted,
    required int currentStreak,
  }) {
    final now = DateTime.now();

    if (lastSessionCompleted != null) {
      final today = DateTime(now.year, now.month, now.day);
      final sessionDay = DateTime(
        lastSessionCompleted.year,
        lastSessionCompleted.month,
        lastSessionCompleted.day,
      );
      if (sessionDay == today) {
        return false;
      }
    }

    if (lastNudgeDismissed != null) {
      final hoursSinceDismiss = now.difference(lastNudgeDismissed).inHours;
      if (hoursSinceDismiss < 4) {
        return false;
      }
    }

    return true;
  }
}
