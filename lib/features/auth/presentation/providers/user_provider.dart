import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  
  final ApiService _apiService = ApiService();
  
  String? _userId;
  String? _email;
  bool _isSubscribed = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  
  int _totalMinutes = 0;
  int _currentStreak = 0;
  int _sessionsCompleted = 0;

  String? get userId => _userId;
  String? get email => _email;
  bool get isSubscribed => _isSubscribed;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  
  int get totalMinutes => _totalMinutes;
  int get currentStreak => _currentStreak;
  int get sessionsCompleted => _sessionsCompleted;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString(_userIdKey);
      _email = prefs.getString(_userEmailKey);

      if (_userId == null) {
        _userId = const Uuid().v4();
        _email = '$_userId@mindflow.app';
        await prefs.setString(_userIdKey, _userId!);
        await prefs.setString(_userEmailKey, _email!);
        
        try {
          await _apiService.createUser(_userId!, _email!);
        } catch (e) {
          debugPrint('Error creating user: $e');
        }
      }

      await refreshSubscriptionStatus();
      await refreshProgress();
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSubscriptionStatus() async {
    if (_userId == null) return;

    try {
      final subscription = await _apiService.getSubscription(_userId!);
      _isSubscribed = subscription != null && 
          (subscription['status'] == 'active' || subscription['status'] == 'trialing');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching subscription: $e');
    }
  }

  Future<void> refreshProgress() async {
    if (_userId == null) return;

    try {
      final progress = await _apiService.getProgress(_userId!);
      _totalMinutes = progress['totalMinutes'] ?? 0;
      _currentStreak = progress['currentStreak'] ?? 0;
      _sessionsCompleted = progress['sessionsCompleted'] ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching progress: $e');
    }
  }

  Future<void> logMeditationSession(String meditationId, int durationSeconds) async {
    if (_userId == null) return;

    try {
      await _apiService.logSession(
        userId: _userId!,
        meditationId: meditationId,
        durationSeconds: durationSeconds,
      );
      await refreshProgress();
    } catch (e) {
      debugPrint('Error logging session: $e');
    }
  }
}
