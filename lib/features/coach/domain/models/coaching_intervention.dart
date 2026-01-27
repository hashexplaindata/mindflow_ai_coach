enum InterventionType {
  nudge,
  celebration,
  milestone,
  recommendation,
  streakWarning,
  streakRecovery,
}

enum ConditioningState {
  newUser,
  habitForming,
  habitEstablished,
}

class CoachingIntervention {
  final String id;
  final InterventionType type;
  final String message;
  final String? subMessage;
  final String? actionLabel;
  final String? meditationId;
  final int? priority;
  final DateTime createdAt;
  final bool requiresAction;
  final Map<String, dynamic>? metadata;

  const CoachingIntervention({
    required this.id,
    required this.type,
    required this.message,
    this.subMessage,
    this.actionLabel,
    this.meditationId,
    this.priority,
    required this.createdAt,
    this.requiresAction = false,
    this.metadata,
  });

  String get icon {
    switch (type) {
      case InterventionType.nudge:
        return '🌿';
      case InterventionType.celebration:
        return '✨';
      case InterventionType.milestone:
        return '🏆';
      case InterventionType.recommendation:
        return '💡';
      case InterventionType.streakWarning:
        return '🔥';
      case InterventionType.streakRecovery:
        return '🌱';
    }
  }

  bool get isUrgent => type == InterventionType.streakWarning;

  bool get isCelebration =>
      type == InterventionType.celebration || type == InterventionType.milestone;

  CoachingIntervention copyWith({
    String? id,
    InterventionType? type,
    String? message,
    String? subMessage,
    String? actionLabel,
    String? meditationId,
    int? priority,
    DateTime? createdAt,
    bool? requiresAction,
    Map<String, dynamic>? metadata,
  }) {
    return CoachingIntervention(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      subMessage: subMessage ?? this.subMessage,
      actionLabel: actionLabel ?? this.actionLabel,
      meditationId: meditationId ?? this.meditationId,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      requiresAction: requiresAction ?? this.requiresAction,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'message': message,
      'subMessage': subMessage,
      'actionLabel': actionLabel,
      'meditationId': meditationId,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'requiresAction': requiresAction,
      'metadata': metadata,
    };
  }

  factory CoachingIntervention.fromJson(Map<String, dynamic> json) {
    return CoachingIntervention(
      id: json['id'] as String,
      type: InterventionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InterventionType.nudge,
      ),
      message: json['message'] as String,
      subMessage: json['subMessage'] as String?,
      actionLabel: json['actionLabel'] as String?,
      meditationId: json['meditationId'] as String?,
      priority: json['priority'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      requiresAction: json['requiresAction'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class UserCoachingState {
  final ConditioningState conditioningState;
  final int totalSessions;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSessionDate;
  final int daysSinceLastSession;
  final bool streakAtRisk;
  final List<String> completedMilestones;
  final int interactionCount;

  const UserCoachingState({
    required this.conditioningState,
    required this.totalSessions,
    required this.currentStreak,
    required this.longestStreak,
    this.lastSessionDate,
    required this.daysSinceLastSession,
    required this.streakAtRisk,
    required this.completedMilestones,
    required this.interactionCount,
  });

  factory UserCoachingState.initial() {
    return const UserCoachingState(
      conditioningState: ConditioningState.newUser,
      totalSessions: 0,
      currentStreak: 0,
      longestStreak: 0,
      daysSinceLastSession: -1,
      streakAtRisk: false,
      completedMilestones: [],
      interactionCount: 0,
    );
  }

  factory UserCoachingState.fromProgress({
    required int totalSessions,
    required int currentStreak,
    required int longestStreak,
    DateTime? lastSessionDate,
    List<String>? completedMilestones,
    int interactionCount = 0,
  }) {
    final now = DateTime.now();
    final daysSinceLastSession = lastSessionDate != null
        ? now.difference(lastSessionDate).inDays
        : -1;
    
    final streakAtRisk = currentStreak > 0 && daysSinceLastSession == 1;

    ConditioningState state;
    if (totalSessions < 3) {
      state = ConditioningState.newUser;
    } else if (currentStreak < 7) {
      state = ConditioningState.habitForming;
    } else {
      state = ConditioningState.habitEstablished;
    }

    return UserCoachingState(
      conditioningState: state,
      totalSessions: totalSessions,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastSessionDate: lastSessionDate,
      daysSinceLastSession: daysSinceLastSession,
      streakAtRisk: streakAtRisk,
      completedMilestones: completedMilestones ?? [],
      interactionCount: interactionCount,
    );
  }
}
