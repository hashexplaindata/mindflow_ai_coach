import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../onboarding/domain/models/nlp_profile.dart';
import '../../domain/models/wisdom_category.dart';
import '../../domain/models/wisdom_item.dart';
import '../../domain/models/gratitude_entry.dart';
import '../../domain/models/user_context.dart';
import '../../domain/services/wisdom_service.dart';

class WisdomProvider extends ChangeNotifier {
  WisdomItem? _todaysWisdom;
  WisdomItem? _gratitudePrompt;
  List<String> _recentlyShownIds = [];
  List<String> _favoriteIds = [];
  List<GratitudeEntry> _gratitudeEntries = [];
  Map<String, bool> _wisdomFeedback = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  NLPProfile? _userProfile;
  String? _lastWisdomDate;
  UserContext? _currentContext;
  
  int _currentStreak = 0;
  int _daysSinceLastSession = 0;
  int _totalSessions = 0;
  int _totalMinutes = 0;

  WisdomItem? get todaysWisdom => _todaysWisdom;
  WisdomItem? get gratitudePrompt => _gratitudePrompt;
  List<String> get favoriteIds => List.unmodifiable(_favoriteIds);
  List<GratitudeEntry> get gratitudeEntries => List.unmodifiable(_gratitudeEntries);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  UserContext? get currentContext => _currentContext;
  String get wisdomGreeting => _currentContext != null 
      ? WisdomService.getPersonalizedGreeting(_currentContext!)
      : WisdomService.getWisdomGreeting();

  List<WisdomItem> get favoriteWisdom {
    return WisdomService.getFavoriteWisdom(_favoriteIds);
  }

  int get gratitudeEntriesThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _gratitudeEntries
        .where((entry) => entry.createdAt.isAfter(weekAgo))
        .length;
  }

  bool get hasWrittenGratitudeToday {
    return _gratitudeEntries.any((entry) => entry.isFromToday);
  }

  Future<void> initialize({NLPProfile? profile}) async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = profile;
      await _loadFromStorage();
      await _refreshDailyWisdom();
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUserProfile(NLPProfile profile) {
    _userProfile = profile;
    _refreshDailyWisdom();
  }

  void updateUserProgress({
    required int currentStreak,
    required int daysSinceLastSession,
    required int totalSessions,
    required int totalMinutes,
  }) {
    _currentStreak = currentStreak;
    _daysSinceLastSession = daysSinceLastSession;
    _totalSessions = totalSessions;
    _totalMinutes = totalMinutes;
    _updateContext();
  }

  void _updateContext() {
    _currentContext = UserContext.fromCurrentState(
      currentStreak: _currentStreak,
      daysSinceLastSession: _daysSinceLastSession,
      totalSessions: _totalSessions,
      totalMinutes: _totalMinutes,
      recentlyShownWisdomIds: _recentlyShownIds,
      wisdomFeedback: _wisdomFeedback,
    );
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final recentIds = prefs.getStringList('wisdom_recently_shown');
    if (recentIds != null) {
      _recentlyShownIds = recentIds;
    }

    final favorites = prefs.getStringList('wisdom_favorites');
    if (favorites != null) {
      _favoriteIds = favorites;
    }

    final entriesJson = prefs.getString('gratitude_entries');
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _gratitudeEntries = decoded.map((e) => GratitudeEntry.fromJson(e)).toList();
      _gratitudeEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final feedbackJson = prefs.getString('wisdom_feedback');
    if (feedbackJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(feedbackJson);
      _wisdomFeedback = decoded.map((k, v) => MapEntry(k, v as bool));
    }

    _lastWisdomDate = prefs.getString('wisdom_last_date');
    
    _updateContext();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('wisdom_recently_shown', _recentlyShownIds);
    await prefs.setStringList('wisdom_favorites', _favoriteIds);
    await prefs.setString('wisdom_last_date', _getTodayString());
    await prefs.setString('wisdom_feedback', jsonEncode(_wisdomFeedback));

    final entriesJson = jsonEncode(_gratitudeEntries.map((e) => e.toJson()).toList());
    await prefs.setString('gratitude_entries', entriesJson);
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> _refreshDailyWisdom() async {
    final todayString = _getTodayString();

    _updateContext();

    if (_lastWisdomDate != todayString || _todaysWisdom == null) {
      _todaysWisdom = WisdomService.getPredictedDailyWisdom(
        profile: _userProfile,
        context: _currentContext!,
      );

      _gratitudePrompt = WisdomService.getGratitudePrompt(
        recentlyShownIds: _recentlyShownIds,
      );

      _recentlyShownIds.add(_todaysWisdom!.id);
      _recentlyShownIds.add(_gratitudePrompt!.id);

      if (_recentlyShownIds.length > 30) {
        _recentlyShownIds = _recentlyShownIds.sublist(_recentlyShownIds.length - 30);
      }

      _lastWisdomDate = todayString;
      await _saveToStorage();
    }

    notifyListeners();
  }

  Future<void> refreshWisdom() async {
    _isLoading = true;
    notifyListeners();

    try {
      _updateContext();
      
      _todaysWisdom = WisdomService.getPredictedDailyWisdom(
        profile: _userProfile,
        context: _currentContext!,
      );
      
      _recentlyShownIds.add(_todaysWisdom!.id);

      if (_recentlyShownIds.length > 30) {
        _recentlyShownIds = _recentlyShownIds.sublist(_recentlyShownIds.length - 30);
      }

      await _saveToStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestNewWisdom() async {
    _isLoading = true;
    notifyListeners();

    try {
      _updateContext();
      
      if (_todaysWisdom != null) {
        _wisdomFeedback[_todaysWisdom!.id] = false;
      }
      
      _todaysWisdom = WisdomService.getPredictedDailyWisdom(
        profile: _userProfile,
        context: _currentContext!.copyWith(
          recentlyShownWisdomIds: [..._recentlyShownIds],
          wisdomFeedback: _wisdomFeedback,
        ),
      );
      
      _recentlyShownIds.add(_todaysWisdom!.id);

      if (_recentlyShownIds.length > 30) {
        _recentlyShownIds = _recentlyShownIds.sublist(_recentlyShownIds.length - 30);
      }

      await _saveToStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordWisdomResonates(String wisdomId) async {
    _wisdomFeedback[wisdomId] = true;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> recordWisdomDoesNotResonate(String wisdomId) async {
    _wisdomFeedback[wisdomId] = false;
    await _saveToStorage();
    notifyListeners();
  }

  bool? getWisdomFeedback(String wisdomId) {
    return _wisdomFeedback[wisdomId];
  }

  Future<void> toggleFavorite(String wisdomId) async {
    if (_favoriteIds.contains(wisdomId)) {
      _favoriteIds.remove(wisdomId);
    } else {
      _favoriteIds.add(wisdomId);
      _wisdomFeedback[wisdomId] = true;
    }

    await _saveToStorage();
    notifyListeners();
  }

  bool isFavorite(String wisdomId) {
    return _favoriteIds.contains(wisdomId);
  }

  Future<void> addGratitudeEntry({
    required String content,
    String? promptId,
  }) async {
    final entry = GratitudeEntry.create(
      userId: 'user',
      content: content,
      promptId: promptId,
    );

    _gratitudeEntries.insert(0, entry);

    await _saveToStorage();
    notifyListeners();
  }

  Future<void> deleteGratitudeEntry(String entryId) async {
    _gratitudeEntries.removeWhere((e) => e.id == entryId);

    await _saveToStorage();
    notifyListeners();
  }

  List<GratitudeEntry> getEntriesForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _gratitudeEntries.where((entry) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      return entryDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  WisdomItem getMindfulnessInsight() {
    return WisdomService.getMindfulnessInsight(recentlyShownIds: _recentlyShownIds);
  }
}
