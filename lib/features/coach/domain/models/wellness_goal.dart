enum GoalType {
  streakDays,
  totalMinutes,
  sessionsPerWeek,
  categoryMastery,
}

enum GoalStatus { active, completed, abandoned }

class WellnessGoal {
  final String id;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final DateTime createdAt;
  final DateTime? completedAt;
  final GoalStatus status;
  final String? category;

  const WellnessGoal({
    required this.id,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.createdAt,
    this.completedAt,
    required this.status,
    this.category,
  });

  double get progressPercent => (currentValue / targetValue).clamp(0.0, 1.0);
  bool get isComplete => currentValue >= targetValue;

  String get title {
    switch (type) {
      case GoalType.streakDays:
        return '$targetValue-Day Streak';
      case GoalType.totalMinutes:
        return '$targetValue Minutes of Mindfulness';
      case GoalType.sessionsPerWeek:
        return '$targetValue Sessions This Week';
      case GoalType.categoryMastery:
        return 'Master ${category ?? 'Category'}';
    }
  }

  String get description {
    switch (type) {
      case GoalType.streakDays:
        return 'Meditate for $targetValue consecutive days';
      case GoalType.totalMinutes:
        return 'Complete $targetValue total minutes of meditation';
      case GoalType.sessionsPerWeek:
        return 'Complete $targetValue sessions this week';
      case GoalType.categoryMastery:
        return 'Complete $targetValue ${category ?? ''} sessions';
    }
  }

  String get progressText {
    switch (type) {
      case GoalType.streakDays:
        return '$currentValue of $targetValue days';
      case GoalType.totalMinutes:
        return '$currentValue of $targetValue min';
      case GoalType.sessionsPerWeek:
        return '$currentValue of $targetValue sessions';
      case GoalType.categoryMastery:
        return '$currentValue of $targetValue sessions';
    }
  }

  IconType get iconType {
    switch (type) {
      case GoalType.streakDays:
        return IconType.fire;
      case GoalType.totalMinutes:
        return IconType.timer;
      case GoalType.sessionsPerWeek:
        return IconType.calendar;
      case GoalType.categoryMastery:
        return IconType.star;
    }
  }

  WellnessGoal copyWith({
    String? id,
    GoalType? type,
    int? targetValue,
    int? currentValue,
    DateTime? createdAt,
    DateTime? completedAt,
    GoalStatus? status,
    String? category,
  }) {
    return WellnessGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }

  factory WellnessGoal.fromJson(Map<String, dynamic> json) {
    return WellnessGoal(
      id: json['id'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.streakDays,
      ),
      targetValue: json['target_value'] as int,
      currentValue: json['current_value'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'target_value': targetValue,
      'current_value': currentValue,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status.name,
      'category': category,
    };
  }
}

enum IconType { fire, timer, calendar, star }

class GoalTemplate {
  final GoalType type;
  final int targetValue;
  final String? category;
  final String motivationalMessage;

  const GoalTemplate({
    required this.type,
    required this.targetValue,
    this.category,
    required this.motivationalMessage,
  });

  static List<GoalTemplate> get starterGoals => [
    const GoalTemplate(
      type: GoalType.streakDays,
      targetValue: 7,
      motivationalMessage: 'Build momentum with a week of daily practice',
    ),
    const GoalTemplate(
      type: GoalType.totalMinutes,
      targetValue: 30,
      motivationalMessage: 'Every minute of mindfulness compounds',
    ),
    const GoalTemplate(
      type: GoalType.sessionsPerWeek,
      targetValue: 3,
      motivationalMessage: 'Consistency beats intensity',
    ),
  ];

  static List<GoalTemplate> get intermediateGoals => [
    const GoalTemplate(
      type: GoalType.streakDays,
      targetValue: 14,
      motivationalMessage: 'Two weeks builds real neural pathways',
    ),
    const GoalTemplate(
      type: GoalType.totalMinutes,
      targetValue: 60,
      motivationalMessage: 'An hour of presence transforms perspective',
    ),
    const GoalTemplate(
      type: GoalType.sessionsPerWeek,
      targetValue: 5,
      motivationalMessage: 'Almost daily practice creates lasting change',
    ),
  ];

  static List<GoalTemplate> get advancedGoals => [
    const GoalTemplate(
      type: GoalType.streakDays,
      targetValue: 30,
      motivationalMessage: 'A month of mindfulness rewires your brain',
    ),
    const GoalTemplate(
      type: GoalType.totalMinutes,
      targetValue: 120,
      motivationalMessage: 'Two hours of accumulated peace',
    ),
    const GoalTemplate(
      type: GoalType.sessionsPerWeek,
      targetValue: 7,
      motivationalMessage: 'Daily practice is the path to mastery',
    ),
  ];

  static List<GoalTemplate> getNextGoals(int completedGoalsCount) {
    if (completedGoalsCount < 2) {
      return starterGoals;
    } else if (completedGoalsCount < 5) {
      return intermediateGoals;
    } else {
      return advancedGoals;
    }
  }
}
