import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// RevenueCat Service for MindFlow AI Coach
/// Handles subscription management and Pro status
///
/// Products:
/// - annual: $39.99/year (7-day free trial)
/// - monthly: $4.99/month
/// - lifetime: $99.99
///
/// Entitlements:
/// - pro: MindFlow AI Coach Pro features
class RevenueCatService {
  RevenueCatService._();

  static final RevenueCatService _instance = RevenueCatService._();
  static RevenueCatService get instance => _instance;

  // Stream controller for Pro status
  final StreamController<bool> _proStatusController =
      StreamController<bool>.broadcast();

  // Cached Pro status
  bool _isPro = false;
  bool _isInitialized = false;

  // API Keys
  // In production, these should be environment variables, but for this contest sprint
  // we are using the provided test key directly as requested.
  static const String _apiKey = 'test_XzdgbSXDiEZMaRkMNMSVmQtqVFG';

  // Product identifiers
  static const String entitlementId = 'pro';

  /// Stream of Pro status changes
  Stream<bool> get proStatusStream => _proStatusController.stream;

  /// Current Pro status (cached)
  bool get isPro => _isPro;

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(_apiKey);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(_apiKey);
      } else {
        // Desktop/Web not supported for this sprint
        _isInitialized = true;
        return;
      }

      await Purchases.configure(configuration);

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updateProStatus(customerInfo);
      });

      // Check initial status
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);

      _isInitialized = true;
      debugPrint('RevenueCat: Initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat: Initialization error: $e');
      // Default to free tier on error
      _setIsPro(false);
      _isInitialized = true;
    }
  }

  /// Update Pro status from CustomerInfo
  void _updateProStatus(CustomerInfo customerInfo) {
    final entitlements = customerInfo.entitlements.active;
    final newIsPro = entitlements.containsKey(entitlementId);
    _setIsPro(newIsPro);
  }

  void _setIsPro(bool value) {
    if (_isPro != value) {
      _isPro = value;
      _proStatusController.add(_isPro);
      debugPrint('RevenueCat: Pro status changed to $_isPro');
    }
  }

  /// Check Pro status (fresh from server)
  Future<bool> checkProStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);
      return _isPro;
    } catch (e) {
      debugPrint('RevenueCat: Error checking pro status: $e');
      return _isPro; // Return cached value on error
    }
  }

  /// Display the Paywall
  /// Returns true if the user purchased or restored Pro
  Future<bool> showPaywall() async {
    try {
      // Use the Paywall UI SDK to present the paywall
      // This automatically handles purchasing and restoring
      final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(
        entitlementId,
        displayCloseButton: true,
      );

      // Check status again after paywall closes
      return await checkProStatus();
    } on PlatformException catch (e) {
      debugPrint('RevenueCat: Error showing paywall: $e');
      return false;
    } catch (e) {
      debugPrint('RevenueCat: Generic error showing paywall: $e');
      return false;
    }
  }

  /// Show Customer Center (Self-Service Portal)
  Future<void> showCustomerCenter() async {
    try {
      // await RevenueCatUI.presentCustomerCenter();
      debugPrint('Customer Center not available in this SDK version');
    } catch (e) {
      debugPrint('RevenueCat: Error showing customer center: $e');
    }
  }

  /// Purchase Pro subscription (Manual flow - use showPaywall instead)
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _updateProStatus(customerInfo);
      return _isPro;
    } catch (e) {
      debugPrint('RevenueCat: Purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatus(customerInfo);
      return _isPro;
    } catch (e) {
      debugPrint('RevenueCat: Restore error: $e');
      return false;
    }
  }

  /// Set user identifier for cross-platform sync
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      await checkProStatus();
      debugPrint('RevenueCat: Logged in as $userId');
    } catch (e) {
      debugPrint('RevenueCat: Error logging in: $e');
    }
  }

  /// Clear user on logout
  Future<void> logout() async {
    try {
      await Purchases.logOut();
      _setIsPro(false);
      debugPrint('RevenueCat: Logged out');
    } catch (e) {
      debugPrint('RevenueCat: Error logging out: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _proStatusController.close();
  }
}
