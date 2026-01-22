import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/revenuecat_service.dart';

/// Subscription Provider for MindFlow AI Coach
/// Manages Pro subscription state using Provider pattern
///
/// Usage:
/// ```dart
/// // In widget tree
/// ChangeNotifierProvider(
///   create: (_) => SubscriptionProvider(),
///   child: MyApp(),
/// )
///
/// // In widgets
/// final isPro = context.watch<SubscriptionProvider>().isPro;
/// ```
class SubscriptionProvider extends ChangeNotifier {
  final RevenueCatService _revenueCatService = RevenueCatService.instance;

  StreamSubscription<bool>? _proStatusSubscription;

  bool _isPro = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  /// Whether the user has Pro subscription
  bool get isPro => _isPro;

  /// Whether a purchase/restore is in progress
  bool get isLoading => _isLoading;

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Error message if last operation failed
  String? get errorMessage => _errorMessage;

  // Free tier limits
  static const int freeDailyChats = 3;

  SubscriptionProvider() {
    _initialize();
  }

  /// Initialize the subscription service
  Future<void> _initialize() async {
    await _revenueCatService.initialize();

    // Subscribe to Pro status changes
    _proStatusSubscription = _revenueCatService.proStatusStream.listen(
      (isPro) {
        _isPro = isPro;
        notifyListeners();
      },
    );

    _isPro = _revenueCatService.isPro;
    _isInitialized = true;
    notifyListeners();
  }

  /// Show Paywall UI
  /// Returns true if user purchased/restored Pro
  Future<bool> showPaywall() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _revenueCatService.showPaywall();

      if (success) {
        _isPro = true;
      }

      return success;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Show Customer Center (Manage Subscription)
  Future<void> showCustomerCenter() async {
    await _revenueCatService.showCustomerCenter();
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _revenueCatService.restorePurchases();

      if (success) {
        _isPro = true;
        _errorMessage = null;
      } else {
        _errorMessage = 'No active Pro subscription found';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Could not restore purchases. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh Pro status from server
  Future<void> refresh() async {
    await _revenueCatService.checkProStatus();
    _isPro = _revenueCatService.isPro;
    notifyListeners();
  }

  /// Set user ID after login
  Future<void> setUserId(String userId) async {
    await _revenueCatService.setUserId(userId);
    _isPro = _revenueCatService.isPro;
    notifyListeners();
  }

  /// Clear user on logout
  Future<void> logout() async {
    await _revenueCatService.logout();
    _isPro = false;
    notifyListeners();
  }

  /// Check if user can send a chat (based on daily limit for free users)
  /// This should be called with the current daily chat count
  bool canSendChat(int currentDailyChats) {
    if (_isPro) return true;
    return currentDailyChats < freeDailyChats;
  }

  /// Get remaining chats for today (for free users)
  int getRemainingChats(int currentDailyChats) {
    if (_isPro) return -1; // Unlimited
    return (freeDailyChats - currentDailyChats).clamp(0, freeDailyChats);
  }

  @override
  void dispose() {
    _proStatusSubscription?.cancel();
    super.dispose();
  }
}
