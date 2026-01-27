import '../domain/models/habit.dart';

class DefaultHabits {
  DefaultHabits._();

  static List<Habit> get all => [
        ...morningHabits,
        ...eveningHabits,
      ];

  static List<Habit> get morningHabits => [
        Habit(
          id: 'default_drink_water',
          name: 'Drink water',
          icon: '💧',
          category: HabitCategory.morning,
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: DateTime.now(),
        ),
        Habit(
          id: 'default_meditate',
          name: 'Meditate 5 minutes',
          icon: '🧘',
          category: HabitCategory.morning,
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: DateTime.now(),
        ),
        Habit(
          id: 'default_stretch',
          name: 'Stretch',
          icon: '🤸',
          category: HabitCategory.morning,
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: DateTime.now(),
        ),
      ];

  static List<Habit> get eveningHabits => [
        Habit(
          id: 'default_gratitude',
          name: 'Gratitude journal',
          icon: '📝',
          category: HabitCategory.evening,
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: DateTime.now(),
        ),
        Habit(
          id: 'default_breathing',
          name: 'Wind-down breathing',
          icon: '🌬️',
          category: HabitCategory.evening,
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: DateTime.now(),
        ),
        Habit(
          id: 'default_no_screens',
          name: 'No screens before bed',
          icon: '📵',
          category: HabitCategory.evening,
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: DateTime.now(),
        ),
      ];

  static List<HabitSuggestion> get suggestions => [
        HabitSuggestion(
          name: 'Drink water',
          icon: '💧',
          category: HabitCategory.morning,
          description: 'Start your day hydrated',
        ),
        HabitSuggestion(
          name: 'Meditate 5 minutes',
          icon: '🧘',
          category: HabitCategory.morning,
          description: 'Center yourself for the day',
        ),
        HabitSuggestion(
          name: 'Stretch',
          icon: '🤸',
          category: HabitCategory.morning,
          description: 'Wake up your body',
        ),
        HabitSuggestion(
          name: 'Morning walk',
          icon: '🚶',
          category: HabitCategory.morning,
          description: 'Get some fresh air',
        ),
        HabitSuggestion(
          name: 'Healthy breakfast',
          icon: '🥗',
          category: HabitCategory.morning,
          description: 'Fuel your body well',
        ),
        HabitSuggestion(
          name: 'Read for 15 minutes',
          icon: '📚',
          category: HabitCategory.afternoon,
          description: 'Expand your mind',
        ),
        HabitSuggestion(
          name: 'Take a break',
          icon: '☕',
          category: HabitCategory.afternoon,
          description: 'Recharge with a pause',
        ),
        HabitSuggestion(
          name: 'Gratitude journal',
          icon: '📝',
          category: HabitCategory.evening,
          description: 'Reflect on what you\'re thankful for',
        ),
        HabitSuggestion(
          name: 'Wind-down breathing',
          icon: '🌬️',
          category: HabitCategory.evening,
          description: 'Calm your nervous system',
        ),
        HabitSuggestion(
          name: 'No screens before bed',
          icon: '📵',
          category: HabitCategory.evening,
          description: 'Prepare for restful sleep',
        ),
        HabitSuggestion(
          name: 'Skincare routine',
          icon: '✨',
          category: HabitCategory.evening,
          description: 'Self-care before sleep',
        ),
        HabitSuggestion(
          name: 'Plan tomorrow',
          icon: '📋',
          category: HabitCategory.evening,
          description: 'Set yourself up for success',
        ),
      ];

  static List<String> get availableIcons => [
    '💧', '🧘', '🤸', '🚶', '🥗', '📚', '☕', '📝', '🌬️', '📵',
    '✨', '📋', '🏃', '💪', '🎯', '🌅', '🌙', '🧠', '❤️', '🙏',
    '🌿', '🍎', '🥤', '💊', '🎨', '🎵', '🧹', '🛏️', '⏰', '🔔',
  ];
}

class HabitSuggestion {
  final String name;
  final String icon;
  final HabitCategory category;
  final String description;

  const HabitSuggestion({
    required this.name,
    required this.icon,
    required this.category,
    required this.description,
  });

  Habit toHabit() {
    return Habit(
      id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      category: category,
      targetDays: [1, 2, 3, 4, 5, 6, 7],
      createdAt: DateTime.now(),
    );
  }
}
