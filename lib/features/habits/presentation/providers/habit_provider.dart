import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/habit.dart';
import '../../domain/models/daily_ritual.dart';
import '../../domain/models/habit_completion.dart';
import '../../data/default_habits.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  List<HabitCompletion> _completions = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  List<Habit> get habits => List.unmodifiable(_habits);
  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  List<DailyRitual> get todayRituals {
    final todayHabits = activeHabits.where((h) => h.shouldShowToday()).toList();
    return DailyRitual.groupByTimeOfDay(todayHabits);
  }

  double get todayProgress {
    final todayHabits = activeHabits.where((h) => h.shouldShowToday()).toList();
    if (todayHabits.isEmpty) return 0.0;
    final completed = todayHabits.where((h) => h.isCompletedToday).length;
    return completed / todayHabits.length;
  }

  int get todayCompletedCount {
    return activeHabits.where((h) => h.shouldShowToday() && h.isCompletedToday).length;
  }

  int get todayTotalCount {
    return activeHabits.where((h) => h.shouldShowToday()).length;
  }

  int get longestStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.streakCount).reduce((a, b) => a > b ? a : b);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _loadHabits();
      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'Failed to load habits';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    final completionsJson = prefs.getString('completions');

    if (habitsJson != null) {
      final List<dynamic> decoded = jsonDecode(habitsJson);
      _habits = decoded.map((h) => Habit.fromJson(h)).toList();
    } else {
      _habits = DefaultHabits.all;
      await _saveHabits();
    }

    if (completionsJson != null) {
      final List<dynamic> decoded = jsonDecode(completionsJson);
      _completions = decoded.map((c) => HabitCompletion.fromJson(c)).toList();
    }

    _recalculateStreaks();
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = jsonEncode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', habitsJson);
  }

  Future<void> _saveCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final completionsJson = jsonEncode(_completions.map((c) => c.toJson()).toList());
    await prefs.setString('completions', completionsJson);
  }

  void _recalculateStreaks() {
    _habits = _habits.map((habit) {
      return habit.copyWith(streakCount: habit.calculateStreak());
    }).toList();
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      await _saveHabits();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    _completions.removeWhere((c) => c.habitId == habitId);
    await _saveHabits();
    await _saveCompletions();
    notifyListeners();
  }

  Future<void> toggleHabitComplete(String habitId) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<DateTime> updatedDates;
    
    if (habit.isCompletedToday) {
      updatedDates = habit.completedDates
          .where((d) {
            final completedDay = DateTime(d.year, d.month, d.day);
            return !completedDay.isAtSameMomentAs(today);
          })
          .toList();

      _completions.removeWhere((c) =>
          c.habitId == habitId && c.isOnDate(today));
    } else {
      updatedDates = [...habit.completedDates, now];

      final completion = HabitCompletion.create(habitId: habitId);
      _completions.add(completion);
    }

    _habits[habitIndex] = habit.copyWith(
      completedDates: updatedDates,
      streakCount: habit.copyWith(completedDates: updatedDates).calculateStreak(),
    );

    await _saveHabits();
    await _saveCompletions();
    notifyListeners();
  }

  List<Habit> getHabitsForTimeOfDay(HabitCategory category) {
    return activeHabits
        .where((h) => h.category == category && h.shouldShowToday())
        .toList();
  }

  List<Habit> getHabitsForCategory(HabitCategory category) {
    return activeHabits.where((h) => h.category == category).toList();
  }

  DailyRitual? getRitualForCategory(HabitCategory category) {
    final habits = getHabitsForTimeOfDay(category);
    if (habits.isEmpty) return null;

    return DailyRitual(
      timeOfDay: category,
      habits: habits,
      date: DateTime.now(),
    );
  }

  Map<DateTime, List<HabitCompletion>> getCompletionHistory(String habitId, int days) {
    final now = DateTime.now();
    final history = <DateTime, List<HabitCompletion>>{};

    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayCompletions = _completions
          .where((c) => c.habitId == habitId && c.isOnDate(date))
          .toList();
      history[date] = dayCompletions;
    }

    return history;
  }

  List<DateTime> getCompletedDatesForHabit(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw Exception('Habit not found'),
    );
    return habit.completedDates;
  }

  DailyCompletionSummary getTodaySummary() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayHabits = activeHabits.where((h) => h.shouldShowToday()).toList();
    final todayCompletions = _completions.where((c) => c.isOnDate(today)).toList();

    return DailyCompletionSummary(
      date: today,
      totalHabits: todayHabits.length,
      completedHabits: todayHabits.where((h) => h.isCompletedToday).length,
      completions: todayCompletions,
    );
  }

  Future<void> resetToDefaults() async {
    _habits = DefaultHabits.all;
    _completions = [];
    await _saveHabits();
    await _saveCompletions();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
