import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/api_service.dart';
import '../../../identity/domain/models/personality_vector.dart';
import 'dart:convert';
import '../../profile/data/trend_repository.dart';
import '../../profile/domain/models/personality_trend.dart';

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
  final PersonalityVector personality;

  const UserState({
    this.userId,
    this.email,
    this.isSubscribed = false,
    this.isInitialized = false,
    this.isLoading = false,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.sessionsCompleted = 0,
    this.personality = PersonalityVector.defaultProfile,
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
    PersonalityVector? personality,
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
      personality: personality ?? this.personality,
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
  static const String _personalityKey = 'personality_vector';

  final ApiService _apiService = ApiService();
  final TrendRepository _trendRepository = TrendRepository();

  @override
  UserState build() {
    return const UserState();
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user is already signed in with Firebase
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // User is already signed in
        await _loginWithFirebaseUser(firebaseUser, prefs);
      } else {
        // Auto sign-in with Google
        await signInWithGoogle();
      }

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      debugPrint('UserProvider: Error initializing user: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true);

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await _loginWithFirebaseUser(firebaseUser, prefs);
      }
    } catch (e) {
      debugPrint('UserProvider: Error signing in with Google: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loginWithFirebaseUser(
      User firebaseUser, SharedPreferences prefs) async {
    final userId = firebaseUser.uid;
    final email = firebaseUser.email ?? '$userId@mindflow.app';

    // CRITICAL: Link Firebase UID to RevenueCat
    try {
      await Purchases.logIn(userId);
      debugPrint('UserProvider: ✅ Linked RevenueCat user: $userId');
    } catch (e) {
      debugPrint('UserProvider: ❌ Error linking RevenueCat user: $e');
    }

    // Save user info
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);

    state = state.copyWith(userId: userId, email: email);

    // Load local progress first
    await _loadLocalProgress(prefs);

    // Start listening to Firestore for subscription status
    _listenToFirestoreSubscription(userId);

    // Try to sync with server
    await refreshProgress();
  }

  void _listenToFirestoreSubscription(String userId) {
    FirebaseFirestore.instance
        .collection('customers')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final isPro = data?['isPro'] ?? false;
        state = state.copyWith(isSubscribed: isPro);
        debugPrint(
            'UserProvider: Subscription status from Firestore: isPro=$isPro');
      }
    }, onError: (error) {
      debugPrint('UserProvider: Error listening to Firestore: $error');
    });
  }

  Future<void> _loadLocalProgress(SharedPreferences prefs) async {
    int totalMinutes = prefs.getInt(_totalMinutesKey) ?? 0;
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int sessionsCompleted = prefs.getInt(_sessionsCompletedKey) ?? 0;

    // Load personality
    PersonalityVector personality = PersonalityVector.defaultProfile;
    final personalityJson = prefs.getString(_personalityKey);
    if (personalityJson != null) {
      try {
        personality = PersonalityVector.fromJson(jsonDecode(personalityJson));
      } catch (e) {
        debugPrint('UserProvider: Error parsing personality JSON: $e');
      }
    }

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
      personality: personality,
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
      await prefs.setString(
          _personalityKey, jsonEncode(state.personality.toJson()));
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
      debugPrint(
          'UserProvider: Error fetching subscription (using Firestore): $e');
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
          state.userId!,
          {
            'meditationId': meditationId,
            'durationSeconds': durationSeconds,
            'minutes': durationSeconds ~/ 60,
          },
        );
        debugPrint('UserProvider: Session synced with server');
      } catch (e) {
        debugPrint(
            'UserProvider: Error logging session to server (saved locally): $e');
      }
    }
  }

  Future<void> updatePersonality(PersonalityVector newPersonality,
      {String reason = 'Manual Update'}) async {
    state = state.copyWith(personality: newPersonality);
    await _saveLocalProgress();

    if (state.userId != null) {
      try {
        // 1. Sync current vector
        await FirebaseFirestore.instance
            .collection('users')
            .doc(state.userId)
            .set({
          'personality': newPersonality.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 2. Save historical trend
        await _trendRepository.saveTrend(
          state.userId!,
          PersonalityTrend(
            timestamp: DateTime.now(),
            vector: newPersonality,
            reason: reason,
          ),
        );
        debugPrint('UserProvider: Personality and Trend synced to Firestore');
      } catch (e) {
        debugPrint('UserProvider: Error syncing personality to Firestore: $e');
      }
    }
  }

  Future<List<PersonalityTrend>> getTrends() async {
    if (state.userId == null) return [];
    try {
      return await _trendRepository.getTrends(state.userId!);
    } catch (e) {
      debugPrint('UserProvider: Error fetching trends: $e');
      return [];
    }
  }

  /// Recalibrates the user's personality vector.
  /// GATED: Only available for Pro subscribers.
  Future<void> recalibrate(PersonalityVector newVector) async {
    if (!state.isSubscribed) {
      debugPrint('UserProvider: 🔒 Recalibration blocked. User is not Pro.');
      throw Exception('Recalibration is a Premium feature.');
    }

    debugPrint('UserProvider: 🧠 Recalibrating personality vector...');
    await updatePersonality(newVector, reason: 'AI Recalibration');
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await Purchases.logOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      state = const UserState();
    } catch (e) {
      debugPrint('UserProvider: Error signing out: $e');
    }
  }
}
