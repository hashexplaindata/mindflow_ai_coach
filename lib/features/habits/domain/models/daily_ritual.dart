import 'habit.dart';

class DailyRitual {
  final HabitCategory timeOfDay;
  final List<Habit> habits;
  final DateTime date;

  const DailyRitual({
    required this.timeOfDay,
    required this.habits,
    required this.date,
  });

  String get title {
    switch (timeOfDay) {
      case HabitCategory.morning:
        return 'Morning Ritual';
      case HabitCategory.afternoon:
        return 'Afternoon Ritual';
      case HabitCategory.evening:
        return 'Evening Ritual';
      case HabitCategory.anytime:
        return 'Daily Habits';
    }
  }

  String get subtitle {
    switch (timeOfDay) {
      case HabitCategory.morning:
        return 'Start your day with intention';
      case HabitCategory.afternoon:
        return 'Maintain your momentum';
      case HabitCategory.evening:
        return 'Wind down peacefully';
      case HabitCategory.anytime:
        return 'Build lasting habits';
    }
  }

  String get emoji {
    return timeOfDay.emoji;
  }

  int get totalHabits => habits.length;

  int get completedHabits => habits.where((h) => h.isCompletedToday).length;

  double get progress {
    if (totalHabits == 0) return 0.0;
    return completedHabits / totalHabits;
  }

  bool get isComplete => completedHabits == totalHabits && totalHabits > 0;

  List<Habit> get activeHabits => habits.where((h) => h.isActive).toList();

  DailyRitual copyWith({
    HabitCategory? timeOfDay,
    List<Habit>? habits,
    DateTime? date,
  }) {
    return DailyRitual(
      timeOfDay: timeOfDay ?? this.timeOfDay,
      habits: habits ?? this.habits,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeOfDay': timeOfDay.name,
      'habits': habits.map((h) => h.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }

  factory DailyRitual.fromJson(Map<String, dynamic> json) {
    return DailyRitual(
      timeOfDay: HabitCategory.values.firstWhere(
        (e) => e.name == json['timeOfDay'],
        orElse: () => HabitCategory.anytime,
      ),
      habits: (json['habits'] as List?)
              ?.map((h) => Habit.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      date: DateTime.parse(json['date'] as String),
    );
  }

  static List<DailyRitual> groupByTimeOfDay(List<Habit> allHabits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final morningHabits =
        allHabits.where((h) => h.category == HabitCategory.morning).toList();
    final afternoonHabits =
        allHabits.where((h) => h.category == HabitCategory.afternoon).toList();
    final eveningHabits =
        allHabits.where((h) => h.category == HabitCategory.evening).toList();
    final anytimeHabits =
        allHabits.where((h) => h.category == HabitCategory.anytime).toList();

    final rituals = <DailyRitual>[];

    if (morningHabits.isNotEmpty) {
      rituals.add(DailyRitual(
        timeOfDay: HabitCategory.morning,
        habits: morningHabits,
        date: today,
      ));
    }

    if (afternoonHabits.isNotEmpty) {
      rituals.add(DailyRitual(
        timeOfDay: HabitCategory.afternoon,
        habits: afternoonHabits,
        date: today,
      ));
    }

    if (eveningHabits.isNotEmpty) {
      rituals.add(DailyRitual(
        timeOfDay: HabitCategory.evening,
        habits: eveningHabits,
        date: today,
      ));
    }

    if (anytimeHabits.isNotEmpty) {
      rituals.add(DailyRitual(
        timeOfDay: HabitCategory.anytime,
        habits: anytimeHabits,
        date: today,
      ));
    }

    return rituals;
  }
}
