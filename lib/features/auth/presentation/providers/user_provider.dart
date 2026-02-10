import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/api_service.dart';

// State class for UserProvider
class UserState {
  final String? userId;
  final String? email;
  final bool isSubscribed;
  final bool isInitialized;
  final bool isLoading;
  final int totalMinutes;
  final int currentStreak;
  final int sessionsCompleted;

  const UserState({
    this.userId,
    this.email,
    this.isSubscribed = false,
    this.isInitialized = false,
    this.isLoading = false,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.sessionsCompleted = 0,
  });

  UserState copyWith({
    String? userId,
    String? email,
    bool? isSubscribed,
    bool? isInitialized,
    bool? isLoading,
    int? totalMinutes,
    int? currentStreak,
    int? sessionsCompleted,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }
}

// Global Provider
final userProvider =
    NotifierProvider<UserNotifier, UserState>(UserNotifier.new);

class UserNotifier extends Notifier<UserState> {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _totalMinutesKey = 'total_minutes';
  static const String _currentStreakKey = 'current_streak';
  static const String _sessionsCompletedKey = 'sessions_completed';
  static const String _lastSessionDateKey = 'last_session_date';

  final ApiService _apiService = ApiService();

  @override
  UserState build() {
    return const UserState();
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString(_userIdKey);
      var email = prefs.getString(_userEmailKey);

      if (userId == null) {
        userId = const Uuid().v4();
        email = '$userId@mindflow.app';
        await prefs.setString(_userIdKey, userId);
        await prefs.setString(_userEmailKey, email);

        try {
          await _apiService.createUser(userId, email);
        } catch (e) {
          debugPrint('UserProvider: Error creating user on API: $e');
        }
      }

      state = state.copyWith(userId: userId, email: email);

      // Load local progress first
      await _loadLocalProgress(prefs);

      // Try to sync with server
      await refreshSubscriptionStatus();
      await refreshProgress();

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      debugPrint('UserProvider: Error initializing user: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadLocalProgress(SharedPreferences prefs) async {
    int totalMinutes = prefs.getInt(_totalMinutesKey) ?? 0;
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int sessionsCompleted = prefs.getInt(_sessionsCompletedKey) ?? 0;

    // Check if streak should be reset (no session yesterday or today)
    final lastSessionDate = prefs.getString(_lastSessionDateKey);
    if (lastSessionDate != null) {
      final lastDate = DateTime.tryParse(lastSessionDate);
      if (lastDate != null) {
        final now = DateTime.now();
        final daysDiff = now.difference(lastDate).inDays;
        if (daysDiff > 1) {
          // More than 1 day gap - reset streak
          currentStreak = 0;
          await prefs.setInt(_currentStreakKey, 0);
        }
      }
    }

    state = state.copyWith(
      totalMinutes: totalMinutes,
      currentStreak: currentStreak,
      sessionsCompleted: sessionsCompleted,
    );

    debugPrint(
        'UserProvider: Loaded local progress - $sessionsCompleted sessions, $totalMinutes mins, $currentStreak day streak');
  }

  Future<void> _saveLocalProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_totalMinutesKey, state.totalMinutes);
      await prefs.setInt(_currentStreakKey, state.currentStreak);
      await prefs.setInt(_sessionsCompletedKey, state.sessionsCompleted);
      await prefs.setString(
          _lastSessionDateKey, DateTime.now().toIso8601String());
      debugPrint('UserProvider: Saved local progress');
    } catch (e) {
      debugPrint('UserProvider: Error saving local progress: $e');
    }
  }

  Future<void> refreshSubscriptionStatus() async {
    if (state.userId == null) return;

    try {
      final subscription = await _apiService.getSubscription(state.userId!);
      final isSubscribed = (subscription['status'] == 'active' ||
          subscription['status'] == 'trialing');
      state = state.copyWith(isSubscribed: isSubscribed);
    } catch (e) {
      debugPrint('UserProvider: Error fetching subscription (using local): $e');
    }
  }

  Future<void> refreshProgress() async {
    if (state.userId == null) return;

    try {
      final progress = await _apiService.getProgress(state.userId!);
      state = state.copyWith(
        totalMinutes: progress['totalMinutes'] ?? state.totalMinutes,
        currentStreak: progress['currentStreak'] ?? state.currentStreak,
        sessionsCompleted:
            progress['sessionsCompleted'] ?? state.sessionsCompleted,
      );

      // Save to local storage as backup
      await _saveLocalProgress();
    } catch (e) {
      debugPrint(
          'UserProvider: Error fetching progress from API (using local): $e');
    }
  }

  Future<void> logMeditationSession(
      String meditationId, int durationSeconds) async {
    // Immediately update local state
    final minutes = durationSeconds ~/ 60;
    int newTotalMinutes = state.totalMinutes + minutes;
    int newSessionsCompleted = state.sessionsCompleted + 1;
    int newCurrentStreak = state.currentStreak;

    // Update streak
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final lastSessionDate = prefs.getString(_lastSessionDateKey);

    if (lastSessionDate != null) {
      final lastDate = DateTime.tryParse(lastSessionDate);
      if (lastDate != null) {
        final daysDiff = now.difference(lastDate).inDays;
        if (daysDiff == 0) {
          // Same day - no streak change
        } else if (daysDiff == 1) {
          // Consecutive day - increment streak
          newCurrentStreak += 1;
        } else {
          // Gap in days - reset streak to 1
          newCurrentStreak = 1;
        }
      } else {
        newCurrentStreak = 1;
      }
    } else {
      // First session ever
      newCurrentStreak = 1;
    }

    state = state.copyWith(
      totalMinutes: newTotalMinutes,
      sessionsCompleted: newSessionsCompleted,
      currentStreak: newCurrentStreak,
    );

    // Save to local storage immediately
    await _saveLocalProgress();

    // Try to sync with server in background
    if (state.userId != null) {
      try {
        await _apiService.logSession(
          userId: state.userId!,
          meditationId: meditationId,
          durationSeconds: durationSeconds,
        );
        debugPrint('UserProvider: Session synced with server');
      } catch (e) {
        debugPrint(
            'UserProvider: Error logging session to server (saved locally): $e');
      }
    }
  }
}
