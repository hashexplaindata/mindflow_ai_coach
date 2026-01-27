import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/coaching_intervention.dart';
import '../../domain/models/intervention_trigger.dart';
import '../../domain/services/background_coach_service.dart';
import '../../../wisdom/domain/models/user_context.dart';
import '../../../habits/domain/models/habit.dart';

class BackgroundCoachProvider extends ChangeNotifier {
  static const String _historyKey = 'intervention_history';
  static const Duration _checkInterval = Duration(minutes: 30);
  static const int _maxHistoryItems = 100;

  final BackgroundCoachService _service = BackgroundCoachService.instance;

  List<InterventionHistory> _history = [];
  CoachingIntervention? _currentIntervention;
  Timer? _periodicTimer;
  bool _isInitialized = false;
  bool _isOverlayVisible = false;
  DateTime? _lastCheckTime;
  VoidCallback? _onInterventionReady;

  bool get isInitialized => _isInitialized;
  bool get isOverlayVisible => _isOverlayVisible;
  CoachingIntervention? get currentIntervention => _currentIntervention;
  List<InterventionHistory> get history => List.unmodifiable(_history);

  void setInterventionCallback(VoidCallback callback) {
    _onInterventionReady = callback;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadHistory();
      _startPeriodicCheck();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing BackgroundCoachProvider: $e');
    }
  }

  void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_checkInterval, (_) {
      _triggerCheck(reason: 'periodic');
    });
  }

  void _triggerCheck({String reason = 'unknown'}) {
    debugPrint('BackgroundCoach: Triggering check (reason: $reason)');
    notifyListeners();
  }

  Future<void> onAppResumed({
    required int currentStreak,
    required int totalSessions,
    required int totalMinutes,
    required int daysSinceLastSession,
    required List<Habit> habits,
    required bool hasCompletedTodaySession,
    double weeklyGoalProgress = 0.0,
  }) async {
    final now = DateTime.now();
    if (_lastCheckTime != null &&
        now.difference(_lastCheckTime!) < const Duration(minutes: 5)) {
      return;
    }
    _lastCheckTime = now;

    await checkForIntervention(
      currentStreak: currentStreak,
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      daysSinceLastSession: daysSinceLastSession,
      habits: habits,
      hasCompletedTodaySession: hasCompletedTodaySession,
      weeklyGoalProgress: weeklyGoalProgress,
    );
  }

  Future<void> onTabChanged({
    required int currentStreak,
    required int totalSessions,
    required int totalMinutes,
    required int daysSinceLastSession,
    required List<Habit> habits,
    required bool hasCompletedTodaySession,
  }) async {
    if (_isOverlayVisible) return;

    final now = DateTime.now();
    if (_lastCheckTime != null &&
        now.difference(_lastCheckTime!) < const Duration(minutes: 10)) {
      return;
    }

    await checkForIntervention(
      currentStreak: currentStreak,
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      daysSinceLastSession: daysSinceLastSession,
      habits: habits,
      hasCompletedTodaySession: hasCompletedTodaySession,
    );
  }

  Future<void> checkForIntervention({
    required int currentStreak,
    required int totalSessions,
    required int totalMinutes,
    required int daysSinceLastSession,
    required List<Habit> habits,
    required bool hasCompletedTodaySession,
    double weeklyGoalProgress = 0.0,
  }) async {
    if (_isOverlayVisible) return;

    final context = UserContext.fromCurrentState(
      currentStreak: currentStreak,
      daysSinceLastSession: daysSinceLastSession,
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
    );

    final intervention = await _service.checkForIntervention(
      context: context,
      recentHistory: _history,
      habits: habits,
      hasCompletedTodaySession: hasCompletedTodaySession,
      weeklyGoalProgress: weeklyGoalProgress,
    );

    if (intervention != null) {
      _currentIntervention = intervention;
      _isOverlayVisible = true;
      notifyListeners();

      _onInterventionReady?.call();
    }
  }

  Future<void> recordInteraction({
    required String action,
    bool dismissed = false,
  }) async {
    if (_currentIntervention == null) return;

    final triggerName = _currentIntervention!.metadata?['trigger'] as String?;
    final trigger = triggerName != null
        ? InterventionTrigger.values.firstWhere(
            (t) => t.name == triggerName,
            orElse: () => InterventionTrigger.morningNudge,
          )
        : InterventionTrigger.morningNudge;

    final historyItem = InterventionHistory(
      id: _currentIntervention!.id,
      trigger: trigger,
      shownAt: DateTime.now(),
      action: action,
      wasInteracted: !dismissed,
      wasDismissed: dismissed,
    );

    _history.insert(0, historyItem);

    if (_history.length > _maxHistoryItems) {
      _history = _history.sublist(0, _maxHistoryItems);
    }

    await _saveHistory();

    _currentIntervention = null;
    _isOverlayVisible = false;
    notifyListeners();
  }

  Future<void> dismissIntervention() async {
    await recordInteraction(action: 'dismissed', dismissed: true);
  }

  Future<void> acceptIntervention(String action) async {
    await recordInteraction(action: action, dismissed: false);
  }

  Future<void> postponeIntervention() async {
    await recordInteraction(action: 'postponed', dismissed: true);
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _history = decoded
            .map((item) => InterventionHistory.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading intervention history: $e');
      _history = [];
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _history.map((h) => h.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error saving intervention history: $e');
    }
  }

  bool hasRecentInteraction(InterventionTrigger trigger, Duration within) {
    final now = DateTime.now();
    return _history.any(
      (h) => h.trigger == trigger && now.difference(h.shownAt) < within,
    );
  }

  int getInteractionCount(InterventionTrigger trigger, {int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _history
        .where((h) => h.trigger == trigger && h.shownAt.isAfter(cutoff))
        .length;
  }

  double getAcceptanceRate(InterventionTrigger trigger, {int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final relevant = _history
        .where((h) => h.trigger == trigger && h.shownAt.isAfter(cutoff))
        .toList();

    if (relevant.isEmpty) return 0.5;

    final accepted = relevant.where((h) => h.wasInteracted).length;
    return accepted / relevant.length;
  }

  Future<void> clearHistory() async {
    _history = [];
    await _saveHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }
}
