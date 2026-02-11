import 'package:flutter/material.dart';

enum InterventionTrigger {
  morningNudge,
  streakAtRisk,
  comebackWelcome,
  milestoneReached,
  eveningWindDown,
  goalProgress,
  habitReminder,
  moodCheck,
}

extension InterventionTriggerExtension on InterventionTrigger {
  String get displayName {
    switch (this) {
      case InterventionTrigger.morningNudge:
        return 'Morning Nudge';
      case InterventionTrigger.streakAtRisk:
        return 'Streak Reminder';
      case InterventionTrigger.comebackWelcome:
        return 'Welcome Back';
      case InterventionTrigger.milestoneReached:
        return 'Milestone';
      case InterventionTrigger.eveningWindDown:
        return 'Wind Down';
      case InterventionTrigger.goalProgress:
        return 'Goal Progress';
      case InterventionTrigger.habitReminder:
        return 'Habit Reminder';
      case InterventionTrigger.moodCheck:
        return 'Mood Check';
    }
  }

  String get icon {
    switch (this) {
      case InterventionTrigger.morningNudge:
        return '🌅';
      case InterventionTrigger.streakAtRisk:
        return '🔥';
      case InterventionTrigger.comebackWelcome:
        return '🌱';
      case InterventionTrigger.milestoneReached:
        return '✨';
      case InterventionTrigger.eveningWindDown:
        return '🌙';
      case InterventionTrigger.goalProgress:
        return '📈';
      case InterventionTrigger.habitReminder:
        return '💫';
      case InterventionTrigger.moodCheck:
        return '💭';
    }
  }

  int get defaultPriority {
    switch (this) {
      case InterventionTrigger.milestoneReached:
        return 10;
      case InterventionTrigger.streakAtRisk:
        return 9;
      case InterventionTrigger.comebackWelcome:
        return 8;
      case InterventionTrigger.habitReminder:
        return 7;
      case InterventionTrigger.morningNudge:
        return 6;
      case InterventionTrigger.eveningWindDown:
        return 5;
      case InterventionTrigger.goalProgress:
        return 4;
      case InterventionTrigger.moodCheck:
        return 3;
    }
  }
}

class InterventionConfig {
  final InterventionTrigger trigger;
  final Duration cooldown;
  final TimeOfDay? activeFrom;
  final TimeOfDay? activeTo;
  final int priority;
  final bool enabled;

  const InterventionConfig({
    required this.trigger,
    required this.cooldown,
    this.activeFrom,
    this.activeTo,
    required this.priority,
    this.enabled = true,
  });

  static List<InterventionConfig> get defaultConfigs => [
    const InterventionConfig(
      trigger: InterventionTrigger.morningNudge,
      cooldown: Duration(hours: 24),
      activeFrom: TimeOfDay(hour: 9, minute: 0),
      activeTo: TimeOfDay(hour: 11, minute: 0),
      priority: 6,
    ),
    const InterventionConfig(
      trigger: InterventionTrigger.streakAtRisk,
      cooldown: Duration(hours: 4),
      activeFrom: TimeOfDay(hour: 20, minute: 0),
      activeTo: TimeOfDay(hour: 22, minute: 0),
      priority: 9,
    ),
    const InterventionConfig(
      trigger: InterventionTrigger.comebackWelcome,
      cooldown: Duration(hours: 24),
      priority: 8,
    ),
    const InterventionConfig(
      trigger: InterventionTrigger.milestoneReached,
      cooldown: Duration(hours: 1),
      priority: 10,
    ),
    const InterventionConfig(
      trigger: InterventionTrigger.eveningWindDown,
      cooldown: Duration(hours: 24),
      activeFrom: TimeOfDay(hour: 21, minute: 0),
      activeTo: TimeOfDay(hour: 23, minute: 0),
      priority: 5,
    ),
    const InterventionConfig(
      trigger: InterventionTrigger.goalProgress,
      cooldown: Duration(hours: 12),
      priority: 4,
    ),
    const InterventionConfig(
      trigger: InterventionTrigger.habitReminder,
      cooldown: Duration(hours: 2),
      priority: 7,
    ),
    const InterventionConfig(
      trigger: InterventionTrigger.moodCheck,
      cooldown: Duration(hours: 6),
      activeFrom: TimeOfDay(hour: 10, minute: 0),
      activeTo: TimeOfDay(hour: 20, minute: 0),
      priority: 3,
    ),
  ];

  bool isActiveAtTime(DateTime time) {
    if (activeFrom == null || activeTo == null) return true;

    final currentMinutes = time.hour * 60 + time.minute;
    final fromMinutes = activeFrom!.hour * 60 + activeFrom!.minute;
    final toMinutes = activeTo!.hour * 60 + activeTo!.minute;

    return currentMinutes >= fromMinutes && currentMinutes <= toMinutes;
  }

  static bool isQuietHours(DateTime time) {
    final hour = time.hour;
    return hour >= 23 || hour < 7;
  }

  InterventionConfig copyWith({
    InterventionTrigger? trigger,
    Duration? cooldown,
    TimeOfDay? activeFrom,
    TimeOfDay? activeTo,
    int? priority,
    bool? enabled,
  }) {
    return InterventionConfig(
      trigger: trigger ?? this.trigger,
      cooldown: cooldown ?? this.cooldown,
      activeFrom: activeFrom ?? this.activeFrom,
      activeTo: activeTo ?? this.activeTo,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger.name,
      'cooldownMinutes': cooldown.inMinutes,
      'activeFromHour': activeFrom?.hour,
      'activeFromMinute': activeFrom?.minute,
      'activeToHour': activeTo?.hour,
      'activeToMinute': activeTo?.minute,
      'priority': priority,
      'enabled': enabled,
    };
  }

  factory InterventionConfig.fromJson(Map<String, dynamic> json) {
    return InterventionConfig(
      trigger: InterventionTrigger.values.firstWhere(
        (e) => e.name == json['trigger'],
        orElse: () => InterventionTrigger.morningNudge,
      ),
      cooldown: Duration(minutes: json['cooldownMinutes'] as int? ?? 60),
      activeFrom: json['activeFromHour'] != null
          ? TimeOfDay(
              hour: json['activeFromHour'] as int,
              minute: json['activeFromMinute'] as int? ?? 0,
            )
          : null,
      activeTo: json['activeToHour'] != null
          ? TimeOfDay(
              hour: json['activeToHour'] as int,
              minute: json['activeToMinute'] as int? ?? 0,
            )
          : null,
      priority: json['priority'] as int? ?? 5,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class InterventionHistory {
  final String id;
  final InterventionTrigger trigger;
  final DateTime shownAt;
  final String? action;
  final bool wasInteracted;
  final bool wasDismissed;

  const InterventionHistory({
    required this.id,
    required this.trigger,
    required this.shownAt,
    this.action,
    this.wasInteracted = false,
    this.wasDismissed = false,
  });

  InterventionHistory copyWith({
    String? id,
    InterventionTrigger? trigger,
    DateTime? shownAt,
    String? action,
    bool? wasInteracted,
    bool? wasDismissed,
  }) {
    return InterventionHistory(
      id: id ?? this.id,
      trigger: trigger ?? this.trigger,
      shownAt: shownAt ?? this.shownAt,
      action: action ?? this.action,
      wasInteracted: wasInteracted ?? this.wasInteracted,
      wasDismissed: wasDismissed ?? this.wasDismissed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trigger': trigger.name,
      'shownAt': shownAt.toIso8601String(),
      'action': action,
      'wasInteracted': wasInteracted,
      'wasDismissed': wasDismissed,
    };
  }

  factory InterventionHistory.fromJson(Map<String, dynamic> json) {
    return InterventionHistory(
      id: json['id'] as String,
      trigger: InterventionTrigger.values.firstWhere(
        (e) => e.name == json['trigger'],
        orElse: () => InterventionTrigger.morningNudge,
      ),
      shownAt: DateTime.parse(json['shownAt'] as String),
      action: json['action'] as String?,
      wasInteracted: json['wasInteracted'] as bool? ?? false,
      wasDismissed: json['wasDismissed'] as bool? ?? false,
    );
  }
}
