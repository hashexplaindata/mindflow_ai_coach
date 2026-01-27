enum UserMood {
  stressed,
  calm,
  motivated,
  tired,
  anxious,
  neutral,
}

extension UserMoodExtension on UserMood {
  String get displayName {
    switch (this) {
      case UserMood.stressed:
        return 'Stressed';
      case UserMood.calm:
        return 'Calm';
      case UserMood.motivated:
        return 'Motivated';
      case UserMood.tired:
        return 'Tired';
      case UserMood.anxious:
        return 'Anxious';
      case UserMood.neutral:
        return 'Neutral';
    }
  }

  String get emoji {
    switch (this) {
      case UserMood.stressed:
        return '😰';
      case UserMood.calm:
        return '😌';
      case UserMood.motivated:
        return '💪';
      case UserMood.tired:
        return '😴';
      case UserMood.anxious:
        return '😟';
      case UserMood.neutral:
        return '😊';
    }
  }
}

enum TimeOfDayPeriod {
  morning,
  afternoon,
  evening,
  night,
}

extension TimeOfDayPeriodExtension on TimeOfDayPeriod {
  String get displayName {
    switch (this) {
      case TimeOfDayPeriod.morning:
        return 'Morning';
      case TimeOfDayPeriod.afternoon:
        return 'Afternoon';
      case TimeOfDayPeriod.evening:
        return 'Evening';
      case TimeOfDayPeriod.night:
        return 'Night';
    }
  }

  static TimeOfDayPeriod fromHour(int hour) {
    if (hour >= 6 && hour < 12) {
      return TimeOfDayPeriod.morning;
    } else if (hour >= 12 && hour < 18) {
      return TimeOfDayPeriod.afternoon;
    } else if (hour >= 18 && hour < 22) {
      return TimeOfDayPeriod.evening;
    } else {
      return TimeOfDayPeriod.night;
    }
  }
}

enum ActivityContext {
  preMeditation,
  postMeditation,
  streakBroken,
  newUser,
  returning,
  streakMaintained,
  longAbsence,
}

extension ActivityContextExtension on ActivityContext {
  String get displayName {
    switch (this) {
      case ActivityContext.preMeditation:
        return 'Pre-Meditation';
      case ActivityContext.postMeditation:
        return 'Post-Meditation';
      case ActivityContext.streakBroken:
        return 'Streak Broken';
      case ActivityContext.newUser:
        return 'New User';
      case ActivityContext.returning:
        return 'Returning';
      case ActivityContext.streakMaintained:
        return 'Streak Maintained';
      case ActivityContext.longAbsence:
        return 'Long Absence';
    }
  }
}

class UserContext {
  final DateTime currentTime;
  final int currentStreak;
  final int daysSinceLastSession;
  final List<String> recentChatTopics;
  final UserMood? inferredMood;
  final double weeklyMeditationMinutes;
  final List<String> activeGoals;
  final bool isWeekend;
  final TimeOfDayPeriod timeOfDay;
  final ActivityContext activityContext;
  final int totalSessions;
  final int totalMinutes;
  final List<String> recentlyShownWisdomIds;
  final Map<String, bool> wisdomFeedback;

  const UserContext({
    required this.currentTime,
    this.currentStreak = 0,
    this.daysSinceLastSession = 0,
    this.recentChatTopics = const [],
    this.inferredMood,
    this.weeklyMeditationMinutes = 0,
    this.activeGoals = const [],
    this.isWeekend = false,
    this.timeOfDay = TimeOfDayPeriod.morning,
    this.activityContext = ActivityContext.newUser,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.recentlyShownWisdomIds = const [],
    this.wisdomFeedback = const {},
  });

  factory UserContext.fromCurrentState({
    required int currentStreak,
    required int daysSinceLastSession,
    required int totalSessions,
    required int totalMinutes,
    List<String> recentChatTopics = const [],
    List<String> activeGoals = const [],
    List<String> recentlyShownWisdomIds = const [],
    Map<String, bool> wisdomFeedback = const {},
  }) {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    return UserContext(
      currentTime: now,
      currentStreak: currentStreak,
      daysSinceLastSession: daysSinceLastSession,
      recentChatTopics: recentChatTopics,
      inferredMood: _inferMood(
        currentStreak: currentStreak,
        daysSinceLastSession: daysSinceLastSession,
        totalMinutes: totalMinutes,
        hour: hour,
      ),
      weeklyMeditationMinutes: totalMinutes.toDouble(),
      activeGoals: activeGoals,
      isWeekend: weekday == DateTime.saturday || weekday == DateTime.sunday,
      timeOfDay: TimeOfDayPeriodExtension.fromHour(hour),
      activityContext: _determineActivityContext(
        currentStreak: currentStreak,
        daysSinceLastSession: daysSinceLastSession,
        totalSessions: totalSessions,
      ),
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      recentlyShownWisdomIds: recentlyShownWisdomIds,
      wisdomFeedback: wisdomFeedback,
    );
  }

  static UserMood _inferMood({
    required int currentStreak,
    required int daysSinceLastSession,
    required int totalMinutes,
    required int hour,
  }) {
    if (daysSinceLastSession > 3) {
      return UserMood.stressed;
    }
    
    if (hour >= 22 || hour < 6) {
      return UserMood.tired;
    }
    
    if (currentStreak >= 7) {
      return UserMood.motivated;
    }
    
    if (currentStreak > 0 && daysSinceLastSession <= 1) {
      return UserMood.calm;
    }
    
    if (daysSinceLastSession == 0 && totalMinutes > 0) {
      return UserMood.calm;
    }
    
    return UserMood.neutral;
  }

  static ActivityContext _determineActivityContext({
    required int currentStreak,
    required int daysSinceLastSession,
    required int totalSessions,
  }) {
    if (totalSessions == 0) {
      return ActivityContext.newUser;
    }
    
    if (daysSinceLastSession > 7) {
      return ActivityContext.longAbsence;
    }
    
    if (currentStreak == 0 && daysSinceLastSession > 1) {
      return ActivityContext.streakBroken;
    }
    
    if (currentStreak >= 3) {
      return ActivityContext.streakMaintained;
    }
    
    if (daysSinceLastSession >= 2 && daysSinceLastSession <= 7) {
      return ActivityContext.returning;
    }
    
    return ActivityContext.returning;
  }

  UserContext copyWith({
    DateTime? currentTime,
    int? currentStreak,
    int? daysSinceLastSession,
    List<String>? recentChatTopics,
    UserMood? inferredMood,
    double? weeklyMeditationMinutes,
    List<String>? activeGoals,
    bool? isWeekend,
    TimeOfDayPeriod? timeOfDay,
    ActivityContext? activityContext,
    int? totalSessions,
    int? totalMinutes,
    List<String>? recentlyShownWisdomIds,
    Map<String, bool>? wisdomFeedback,
  }) {
    return UserContext(
      currentTime: currentTime ?? this.currentTime,
      currentStreak: currentStreak ?? this.currentStreak,
      daysSinceLastSession: daysSinceLastSession ?? this.daysSinceLastSession,
      recentChatTopics: recentChatTopics ?? this.recentChatTopics,
      inferredMood: inferredMood ?? this.inferredMood,
      weeklyMeditationMinutes: weeklyMeditationMinutes ?? this.weeklyMeditationMinutes,
      activeGoals: activeGoals ?? this.activeGoals,
      isWeekend: isWeekend ?? this.isWeekend,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      activityContext: activityContext ?? this.activityContext,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      recentlyShownWisdomIds: recentlyShownWisdomIds ?? this.recentlyShownWisdomIds,
      wisdomFeedback: wisdomFeedback ?? this.wisdomFeedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentTime': currentTime.toIso8601String(),
      'currentStreak': currentStreak,
      'daysSinceLastSession': daysSinceLastSession,
      'recentChatTopics': recentChatTopics,
      'inferredMood': inferredMood?.name,
      'weeklyMeditationMinutes': weeklyMeditationMinutes,
      'activeGoals': activeGoals,
      'isWeekend': isWeekend,
      'timeOfDay': timeOfDay.name,
      'activityContext': activityContext.name,
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'recentlyShownWisdomIds': recentlyShownWisdomIds,
      'wisdomFeedback': wisdomFeedback,
    };
  }

  factory UserContext.fromJson(Map<String, dynamic> json) {
    return UserContext(
      currentTime: DateTime.parse(json['currentTime'] as String),
      currentStreak: json['currentStreak'] as int? ?? 0,
      daysSinceLastSession: json['daysSinceLastSession'] as int? ?? 0,
      recentChatTopics: List<String>.from(json['recentChatTopics'] ?? []),
      inferredMood: json['inferredMood'] != null
          ? UserMood.values.firstWhere(
              (e) => e.name == json['inferredMood'],
              orElse: () => UserMood.neutral,
            )
          : null,
      weeklyMeditationMinutes: (json['weeklyMeditationMinutes'] as num?)?.toDouble() ?? 0,
      activeGoals: List<String>.from(json['activeGoals'] ?? []),
      isWeekend: json['isWeekend'] as bool? ?? false,
      timeOfDay: TimeOfDayPeriod.values.firstWhere(
        (e) => e.name == json['timeOfDay'],
        orElse: () => TimeOfDayPeriod.morning,
      ),
      activityContext: ActivityContext.values.firstWhere(
        (e) => e.name == json['activityContext'],
        orElse: () => ActivityContext.newUser,
      ),
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      recentlyShownWisdomIds: List<String>.from(json['recentlyShownWisdomIds'] ?? []),
      wisdomFeedback: Map<String, bool>.from(json['wisdomFeedback'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'UserContext(timeOfDay: $timeOfDay, mood: $inferredMood, streak: $currentStreak, activity: $activityContext)';
  }
}
