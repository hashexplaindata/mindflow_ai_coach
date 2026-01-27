import 'dart:math';
import '../models/coaching_intervention.dart';
import 'encouragement_engine.dart';

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
      return EncouragementEngine.getComebackReward(
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

  // Streak reminders: Supportive, not threatening
  // Invite without pressure or urgency
  static CoachingIntervention _getStreakWarning({
    required String id,
    required int streak,
    required DateTime now,
  }) {
    final hoursLeft = 24 - now.hour;
    
    final messages = [
      'You\'ve practiced $streak days in a row. A few minutes keeps it going.',
      'Your $streak-day journey continues whenever you\'re ready.',
      'If you\'d like to continue your streak, a short session is all it takes.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.streakWarning,
      message: messages[_random.nextInt(messages.length)],
      subMessage: 'No pressure. The practice is here when you need it.',
      actionLabel: 'Continue',
      createdAt: now,
      priority: 9,
      requiresAction: false,
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
      subMessage = 'A calm start to the day.';
      actionLabel = 'Morning Calm';
      meditationCategory = 'focus';
    } else if (hour >= 10 && hour < 14) {
      final middayNudges = _getMiddayNudges(state);
      message = middayNudges[_random.nextInt(middayNudges.length)];
      subMessage = 'A midday moment of stillness.';
      actionLabel = 'Quick Reset';
      meditationCategory = 'stress';
    } else if (hour >= 14 && hour < 18) {
      final afternoonNudges = _getAfternoonNudges(state);
      message = afternoonNudges[_random.nextInt(afternoonNudges.length)];
      subMessage = 'Rest before the final stretch.';
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

  // Morning nudges: Gentle, experiential
  static List<String> _getMorningNudges(UserCoachingState state) {
    switch (state.practiceStage) {
      case PracticeStage.newUser:
        return [
          'Good morning. Your mind is fresh and receptive.',
          'Before the day begins. A few minutes of stillness.',
          'Start quiet. The noise comes later.',
          'Morning calm shapes the whole day.',
        ];
      case PracticeStage.developing:
        return [
          'Good morning. Day ${state.currentStreak + 1} awaits.',
          'Your morning practice is taking shape.',
          'Same time, same calm. Building something real.',
          'The morning ritual is becoming familiar.',
        ];
      case PracticeStage.established:
        return [
          'Your morning practice awaits.',
          'The mind you\'ve built knows what it needs.',
          'Another morning, another layer of peace.',
          'This is just what you do now. Show up.',
        ];
    }
  }

  // Midday nudges: Simple reset invitation
  static List<String> _getMiddayNudges(UserCoachingState state) {
    return [
      'Halfway through. A moment to pause.',
      'Five minutes can change the whole afternoon.',
      'Step back from the noise. Just briefly.',
      'A midday reset goes a long way.',
    ];
  }

  // Afternoon nudges: Gentle energy renewal
  static List<String> _getAfternoonNudges(UserCoachingState state) {
    return [
      'Afternoon fatigue is natural. Stillness helps.',
      'A few minutes of calm before the final push.',
      'Rest your mind. The day isn\'t over yet.',
      'Recharge with presence, not caffeine.',
    ];
  }

  // Evening nudges: Wind-down invitation
  static List<String> _getEveningNudges(UserCoachingState state) {
    return [
      'The day is winding down. Wind down with it.',
      'Process the day. Let go of what you don\'t need.',
      'Evening stillness leads to morning clarity.',
      'Prepare for rest. You\'ve earned it.',
    ];
  }

  // Night nudges: Sleep preparation
  static List<String> _getNightNudges(UserCoachingState state) {
    return [
      'Quiet the mind for deeper sleep.',
      'A sleep story awaits.',
      'Let tonight restore tomorrow\'s energy.',
      'The last moments before sleep matter.',
    ];
  }

  static CoachingIntervention? getCelebration({
    required int sessionsCompleted,
    required int currentStreak,
    required int durationMinutes,
    required int totalMinutes,
  }) {
    final state = _getPracticeStage(sessionsCompleted, currentStreak);

    return EncouragementEngine.getCelebration(
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
      reason = 'A calm start helps the whole day unfold.';
    } else if (hour >= 10 && hour < 14) {
      category = 'stress';
      title = 'Stress Relief';
      reason = 'A midday pause goes a long way.';
    } else if (hour >= 14 && hour < 18) {
      category = 'focus';
      title = 'Afternoon Clarity';
      reason = 'Rest your mind before the final stretch.';
    } else if (hour >= 18 && hour < 22) {
      category = 'anxiety';
      title = 'Evening Calm';
      reason = 'Settle the day gently.';
    } else {
      category = 'sleep';
      title = 'Sleep Preparation';
      reason = 'A quiet mind invites restful sleep.';
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

  static PracticeStage _getPracticeStage(int sessions, int streak) {
    if (sessions < 3) return PracticeStage.newUser;
    if (streak < 7) return PracticeStage.developing;
    return PracticeStage.established;
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
