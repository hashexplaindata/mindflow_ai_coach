import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// RevenueCat Service for MindFlow AI Coach
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
      String? apiKey;
      if (defaultTargetPlatform == TargetPlatform.android) {
        apiKey = dotenv.env['REVENUECAT_ANDROID_KEY'];
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        apiKey = dotenv.env['REVENUECAT_IOS_KEY'];
      } else {
        // Desktop/Web not supported
        debugPrint(
            'RevenueCat: ⚠️ Web/Desktop not supported for payments. Defaulting to Free Tier.');
        _isInitialized = true;
        return;
      }

      await Purchases.setLogLevel(LogLevel.debug);

      if (apiKey == null || apiKey.isEmpty) {
        debugPrint(
            'RevenueCat: ❌ API key not found in .env! (REVENUECAT_ANDROID_KEY / REVENUECAT_IOS_KEY)');
        debugPrint('RevenueCat: Payments will NOT work.');
        _isInitialized = true;
        return;
      }

      final configuration = PurchasesConfiguration(apiKey);

      await Purchases.configure(configuration);

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updateProStatus(customerInfo);
      });

      // Check initial status
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);

      _isInitialized = true;
      debugPrint('RevenueCat: ✅ Initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat: ❌ Initialization error: $e');
      debugPrint(
          'RevenueCat: Possible causes: Invalid API Key, Network Issue, or Misconfiguration in RevenueCat Console.');
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
    if (kIsWeb) return _isPro; // Mock for web

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
    if (kIsWeb) {
      debugPrint('RevenueCat: Paywall not supported on web');
      // Mock successful purchase for testing web flow if needed, or just return false
      return false;
    }

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
    if (kIsWeb) return;

    try {
      // await RevenueCatUI.presentCustomerCenter();
      debugPrint('Customer Center not available in this SDK version');
    } catch (e) {
      debugPrint('RevenueCat: Error showing customer center: $e');
    }
  }

  /// Purchase Pro subscription (Manual flow - use showPaywall instead)
  Future<bool> purchasePackage(Package package) async {
    if (kIsWeb) return false;

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
    if (kIsWeb) return false;

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
    if (kIsWeb) {
      debugPrint('RevenueCat: Web mock login as $userId');
      return;
    }

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
    if (kIsWeb) {
      _setIsPro(false);
      return;
    }

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
