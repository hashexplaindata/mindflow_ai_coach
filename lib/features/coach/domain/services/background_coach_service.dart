import 'dart:math';
import '../models/coaching_intervention.dart';
import '../models/intervention_trigger.dart';
import '../../../wisdom/domain/models/user_context.dart';
import '../../../habits/domain/models/habit.dart';
import 'encouragement_engine.dart';

class BackgroundCoachService {
  BackgroundCoachService._();

  static final BackgroundCoachService instance = BackgroundCoachService._();

  static final Random _random = Random();

  final List<InterventionConfig> _configs = InterventionConfig.defaultConfigs;

  Future<CoachingIntervention?> checkForIntervention({
    required UserContext context,
    required List<InterventionHistory> recentHistory,
    List<Habit> habits = const [],
    DateTime? lastSessionDate,
    bool hasCompletedTodaySession = false,
    double weeklyGoalProgress = 0.0,
  }) async {
    final now = context.currentTime;

    if (InterventionConfig.isQuietHours(now)) {
      return null;
    }

    final interventions = <CoachingIntervention>[];

    final milestone = _checkMilestone(context, recentHistory);
    if (milestone != null) interventions.add(milestone);

    final comeback = _checkComebackWelcome(context, recentHistory);
    if (comeback != null) interventions.add(comeback);

    final streakRisk = _checkStreakAtRisk(context, recentHistory, hasCompletedTodaySession);
    if (streakRisk != null) interventions.add(streakRisk);

    final morningNudge = _checkMorningNudge(context, recentHistory, hasCompletedTodaySession);
    if (morningNudge != null) interventions.add(morningNudge);

    final windDown = _checkEveningWindDown(context, recentHistory, hasCompletedTodaySession);
    if (windDown != null) interventions.add(windDown);

    final habitReminder = _checkHabitReminders(context, recentHistory, habits);
    if (habitReminder != null) interventions.add(habitReminder);

    final goalProgress = _checkGoalProgress(context, recentHistory, weeklyGoalProgress);
    if (goalProgress != null) interventions.add(goalProgress);

    if (interventions.isEmpty) {
      return null;
    }

    interventions.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));

    return interventions.first;
  }

  bool _isOnCooldown(InterventionTrigger trigger, List<InterventionHistory> history) {
    final config = _configs.firstWhere(
      (c) => c.trigger == trigger,
      orElse: () => InterventionConfig(
        trigger: trigger,
        cooldown: const Duration(hours: 1),
        priority: 5,
      ),
    );

    final now = DateTime.now();
    final recentShows = history.where(
      (h) => h.trigger == trigger && now.difference(h.shownAt) < config.cooldown,
    );

    return recentShows.isNotEmpty;
  }

  CoachingIntervention? _checkMilestone(
    UserContext context,
    List<InterventionHistory> history,
  ) {
    if (_isOnCooldown(InterventionTrigger.milestoneReached, history)) {
      return null;
    }

    if (!EncouragementEngine.isNewMilestone(context.currentStreak)) {
      return null;
    }

    final alreadyCelebrated = history.any(
      (h) =>
          h.trigger == InterventionTrigger.milestoneReached &&
          h.shownAt.day == context.currentTime.day &&
          h.shownAt.month == context.currentTime.month,
    );

    if (alreadyCelebrated) return null;

    final id = 'milestone_${context.currentTime.millisecondsSinceEpoch}';
    final title = EncouragementEngine.getMilestoneTitle(context.currentStreak);

    return CoachingIntervention(
      id: id,
      type: InterventionType.milestone,
      message: title,
      subMessage: _getMilestoneSubMessage(context.currentStreak),
      actionLabel: 'Celebrate',
      createdAt: context.currentTime,
      priority: 10,
      metadata: {
        'trigger': InterventionTrigger.milestoneReached.name,
        'streak': context.currentStreak,
      },
    );
  }

  String _getMilestoneSubMessage(int streak) {
    switch (streak) {
      case 1:
        return 'You showed up. That\'s the foundation.';
      case 3:
        return 'Three days. Something is shifting.';
      case 7:
        return 'A full week of presence. Remarkable.';
      case 14:
        return 'Two weeks. This is becoming you.';
      case 21:
        return 'Three weeks. The practice has found its rhythm.';
      case 30:
        return 'One month. You\'ve proven something.';
      default:
        return 'Every session matters.';
    }
  }

  CoachingIntervention? _checkComebackWelcome(
    UserContext context,
    List<InterventionHistory> history,
  ) {
    if (_isOnCooldown(InterventionTrigger.comebackWelcome, history)) {
      return null;
    }

    if (context.daysSinceLastSession < 3) {
      return null;
    }

    final id = 'comeback_${context.currentTime.millisecondsSinceEpoch}';

    final messages = [
      'Welcome back. The practice waited for you.',
      'Good to see you again. Pick up wherever feels right.',
      'You\'re here. That\'s what matters.',
      'The path is still here. No judgment, just presence.',
    ];

    final subMessages = [
      'Even a short session can reconnect you.',
      'Start with just a few breaths.',
      'No need to make up for lost time. Just begin.',
      'The moment you return, the practice begins anew.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.streakRecovery,
      message: messages[_random.nextInt(messages.length)],
      subMessage: subMessages[_random.nextInt(subMessages.length)],
      actionLabel: 'Begin Again',
      createdAt: context.currentTime,
      priority: 8,
      metadata: {
        'trigger': InterventionTrigger.comebackWelcome.name,
        'daysSinceLastSession': context.daysSinceLastSession,
      },
    );
  }

  CoachingIntervention? _checkStreakAtRisk(
    UserContext context,
    List<InterventionHistory> history,
    bool hasCompletedTodaySession,
  ) {
    if (hasCompletedTodaySession) return null;

    if (_isOnCooldown(InterventionTrigger.streakAtRisk, history)) {
      return null;
    }

    final config = _configs.firstWhere(
      (c) => c.trigger == InterventionTrigger.streakAtRisk,
    );
    if (!config.isActiveAtTime(context.currentTime)) {
      return null;
    }

    if (context.currentStreak < 2) {
      return null;
    }

    final id = 'streak_risk_${context.currentTime.millisecondsSinceEpoch}';
    final streak = context.currentStreak;

    final messages = [
      'Your $streak-day journey continues whenever you\'re ready.',
      'A few quiet minutes will keep your streak going.',
      '$streak days of presence. Today can be another.',
      'If you\'d like to continue, a short session is all it takes.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.streakWarning,
      message: messages[_random.nextInt(messages.length)],
      subMessage: 'No pressure. The practice is here when you need it.',
      actionLabel: 'Continue Streak',
      createdAt: context.currentTime,
      priority: 9,
      metadata: {
        'trigger': InterventionTrigger.streakAtRisk.name,
        'streak': streak,
      },
    );
  }

  CoachingIntervention? _checkMorningNudge(
    UserContext context,
    List<InterventionHistory> history,
    bool hasCompletedTodaySession,
  ) {
    if (hasCompletedTodaySession) return null;

    if (_isOnCooldown(InterventionTrigger.morningNudge, history)) {
      return null;
    }

    final config = _configs.firstWhere(
      (c) => c.trigger == InterventionTrigger.morningNudge,
    );
    if (!config.isActiveAtTime(context.currentTime)) {
      return null;
    }

    final id = 'morning_${context.currentTime.millisecondsSinceEpoch}';

    final messages = [
      'Your morning practice awaits.',
      'Good morning. A calm start shapes the whole day.',
      'Before the day begins. A few minutes of stillness.',
      'Morning mind is fresh and receptive.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.nudge,
      message: messages[_random.nextInt(messages.length)],
      subMessage: 'A gentle way to begin.',
      actionLabel: 'Morning Calm',
      createdAt: context.currentTime,
      priority: 6,
      metadata: {
        'trigger': InterventionTrigger.morningNudge.name,
        'category': 'focus',
      },
    );
  }

  CoachingIntervention? _checkEveningWindDown(
    UserContext context,
    List<InterventionHistory> history,
    bool hasCompletedTodaySession,
  ) {
    if (_isOnCooldown(InterventionTrigger.eveningWindDown, history)) {
      return null;
    }

    final config = _configs.firstWhere(
      (c) => c.trigger == InterventionTrigger.eveningWindDown,
    );
    if (!config.isActiveAtTime(context.currentTime)) {
      return null;
    }

    final id = 'winddown_${context.currentTime.millisecondsSinceEpoch}';

    final messages = [
      'The day is winding down. Wind down with it.',
      'Ready to let go of the day?',
      'Evening is for releasing. Prepare for rest.',
      'A calm mind sleeps well.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.nudge,
      message: messages[_random.nextInt(messages.length)],
      subMessage: 'Transition into restful sleep.',
      actionLabel: 'Wind Down',
      createdAt: context.currentTime,
      priority: 5,
      metadata: {
        'trigger': InterventionTrigger.eveningWindDown.name,
        'category': 'sleep',
      },
    );
  }

  CoachingIntervention? _checkHabitReminders(
    UserContext context,
    List<InterventionHistory> history,
    List<Habit> habits,
  ) {
    if (_isOnCooldown(InterventionTrigger.habitReminder, history)) {
      return null;
    }

    final now = context.currentTime;
    final hour = now.hour;

    HabitCategory? currentWindow;
    if (hour >= 6 && hour < 12) {
      currentWindow = HabitCategory.morning;
    } else if (hour >= 12 && hour < 18) {
      currentWindow = HabitCategory.afternoon;
    } else if (hour >= 18 && hour < 22) {
      currentWindow = HabitCategory.evening;
    }

    if (currentWindow == null) return null;

    final pendingHabits = habits.where((h) =>
        h.isActive &&
        h.shouldShowToday() &&
        !h.isCompletedToday &&
        (h.category == currentWindow || h.category == HabitCategory.anytime),
    ).toList();

    if (pendingHabits.isEmpty) return null;

    final habit = pendingHabits[_random.nextInt(pendingHabits.length)];
    final id = 'habit_${context.currentTime.millisecondsSinceEpoch}';

    final templates = [
      'Your ${habit.name.toLowerCase()} is waiting for you.',
      'Time for ${habit.name.toLowerCase()}? You\'ve got this.',
      'A gentle reminder: ${habit.name.toLowerCase()}.',
      '${habit.name} — when you\'re ready.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.nudge,
      message: templates[_random.nextInt(templates.length)],
      subMessage: 'Small steps build lasting change.',
      actionLabel: 'View Habits',
      createdAt: context.currentTime,
      priority: 7,
      metadata: {
        'trigger': InterventionTrigger.habitReminder.name,
        'habitId': habit.id,
        'habitName': habit.name,
      },
    );
  }

  CoachingIntervention? _checkGoalProgress(
    UserContext context,
    List<InterventionHistory> history,
    double progress,
  ) {
    if (_isOnCooldown(InterventionTrigger.goalProgress, history)) {
      return null;
    }

    if (progress < 0.7 || progress >= 1.0) {
      return null;
    }

    final id = 'goal_${context.currentTime.millisecondsSinceEpoch}';
    final percentage = (progress * 100).round();

    final messages = [
      'You\'re $percentage% to your weekly goal.',
      'Almost there — $percentage% complete this week.',
      'Strong progress: $percentage% of your goal reached.',
    ];

    return CoachingIntervention(
      id: id,
      type: InterventionType.nudge,
      message: messages[_random.nextInt(messages.length)],
      subMessage: 'Keep the momentum going.',
      actionLabel: 'View Progress',
      createdAt: context.currentTime,
      priority: 4,
      metadata: {
        'trigger': InterventionTrigger.goalProgress.name,
        'progress': progress,
      },
    );
  }
}
