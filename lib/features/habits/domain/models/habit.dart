import 'package:flutter/material.dart';

enum HabitCategory {
  morning,
  afternoon,
  evening,
  anytime,
}

extension HabitCategoryExtension on HabitCategory {
  String get displayName {
    switch (this) {
      case HabitCategory.morning:
        return 'Morning';
      case HabitCategory.afternoon:
        return 'Afternoon';
      case HabitCategory.evening:
        return 'Evening';
      case HabitCategory.anytime:
        return 'Anytime';
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.morning:
        return '🌅';
      case HabitCategory.afternoon:
        return '☀️';
      case HabitCategory.evening:
        return '🌙';
      case HabitCategory.anytime:
        return '⏰';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitCategory.morning:
        return Icons.wb_sunny_rounded;
      case HabitCategory.afternoon:
        return Icons.light_mode_rounded;
      case HabitCategory.evening:
        return Icons.nights_stay_rounded;
      case HabitCategory.anytime:
        return Icons.access_time_rounded;
    }
  }
}

class Habit {
  final String id;
  final String name;
  final String icon;
  final HabitCategory category;
  final List<int> targetDays;
  final List<DateTime> completedDates;
  final int streakCount;
  final bool isActive;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.targetDays,
    this.completedDates = const [],
    this.streakCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isCompletedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completedDates.any((date) {
      final completedDay = DateTime(date.year, date.month, date.day);
      return completedDay.isAtSameMomentAs(today);
    });
  }

  bool isCompletedOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return completedDates.any((d) {
      final completedDay = DateTime(d.year, d.month, d.day);
      return completedDay.isAtSameMomentAs(targetDate);
    });
  }

  bool shouldShowToday() {
    if (!isActive) return false;
    if (targetDays.isEmpty) return true;
    final today = DateTime.now().weekday;
    return targetDays.contains(today);
  }

  int calculateStreak() {
    if (completedDates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (final date in sortedDates) {
      final completedDay = DateTime(date.year, date.month, date.day);
      final diff = checkDate.difference(completedDay).inDays;

      if (diff == 0 || diff == 1) {
        streak++;
        checkDate = completedDay;
      } else {
        break;
      }
    }

    return streak;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    HabitCategory? category,
    List<int>? targetDays,
    List<DateTime>? completedDates,
    int? streakCount,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      targetDays: targetDays ?? this.targetDays,
      completedDates: completedDates ?? this.completedDates,
      streakCount: streakCount ?? this.streakCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category.name,
      'targetDays': targetDays,
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'streakCount': streakCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HabitCategory.anytime,
      ),
      targetDays: List<int>.from(json['targetDays'] ?? []),
      completedDates: (json['completedDates'] as List?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
      streakCount: json['streakCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
