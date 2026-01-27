class HabitCompletion {
  final String id;
  final String habitId;
  final DateTime completedAt;
  final String? note;
  final int durationMinutes;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.note,
    this.durationMinutes = 0,
  });

  DateTime get completedDate {
    return DateTime(completedAt.year, completedAt.month, completedAt.day);
  }

  bool isOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return completedDate.isAtSameMomentAs(targetDate);
  }

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? completedAt,
    String? note,
    int? durationMinutes,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'completedAt': completedAt.toIso8601String(),
      'note': note,
      'durationMinutes': durationMinutes,
    };
  }

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      note: json['note'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
    );
  }

  factory HabitCompletion.create({
    required String habitId,
    String? note,
    int durationMinutes = 0,
  }) {
    return HabitCompletion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      habitId: habitId,
      completedAt: DateTime.now(),
      note: note,
      durationMinutes: durationMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCompletion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DailyCompletionSummary {
  final DateTime date;
  final int totalHabits;
  final int completedHabits;
  final List<HabitCompletion> completions;

  const DailyCompletionSummary({
    required this.date,
    required this.totalHabits,
    required this.completedHabits,
    required this.completions,
  });

  double get completionRate {
    if (totalHabits == 0) return 0.0;
    return completedHabits / totalHabits;
  }

  bool get isComplete => completedHabits == totalHabits && totalHabits > 0;

  bool get hasAnyCompletion => completedHabits > 0;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completions': completions.map((c) => c.toJson()).toList(),
    };
  }

  factory DailyCompletionSummary.fromJson(Map<String, dynamic> json) {
    return DailyCompletionSummary(
      date: DateTime.parse(json['date'] as String),
      totalHabits: json['totalHabits'] as int,
      completedHabits: json['completedHabits'] as int,
      completions: (json['completions'] as List?)
              ?.map((c) => HabitCompletion.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
